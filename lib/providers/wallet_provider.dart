import 'package:flutter/foundation.dart';
import '../models/wallet.dart';
import '../models/tip.dart';
import '../services/blockchain_service.dart';
import '../services/wallet_service.dart';

class WalletProvider with ChangeNotifier {
  final BlockchainService _blockchainService;
  final WalletService _walletService;
  
  WalletConnection _wallet = WalletConnection.disconnected();
  List<Tip> _sentTips = [];
  List<Tip> _receivedTips = [];
  bool _isLoading = false;
  String? _error;

  WalletProvider()
      : _blockchainService = BlockchainService(),
        _walletService = WalletService(BlockchainService()) {
    _loadWallet();
  }

  // Getters
  WalletConnection get wallet => _wallet;
  List<Tip> get sentTips => _sentTips;
  List<Tip> get receivedTips => _receivedTips;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _wallet.isConnected;
  bool get hasWallet => _wallet.address.isNotEmpty;

  // Load wallet from storage
  Future<void> _loadWallet() async {
    _setLoading(true);
    try {
      final savedWallet = await _walletService.loadWallet();
      if (savedWallet != null) {
        _wallet = savedWallet;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to load wallet: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Generate new wallet
  Future<void> generateWallet() async {
    _setLoading(true);
    _clearError();
    
    try {
      final walletData = await _walletService.generateWallet();
      
      await _walletService.saveWallet(
        privateKey: walletData['privateKey']!,
        address: walletData['address']!,
        mnemonic: walletData['mnemonic']!,
      );
      
      _wallet = WalletConnection(
        address: walletData['address']!,
        balance: '0.0',
        isConnected: true,
        networkName: ShardeumNetwork.name,
        chainId: ShardeumNetwork.chainId,
      );
      
      await refreshBalance();
      notifyListeners();
    } catch (e) {
      _setError('Failed to generate wallet: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Import wallet from private key
  Future<void> importFromPrivateKey(String privateKey) async {
    _setLoading(true);
    _clearError();
    
    try {
      final address = await _walletService.importFromPrivateKey(privateKey);
      
      await _walletService.saveWallet(
        privateKey: privateKey.startsWith('0x') ? privateKey.substring(2) : privateKey,
        address: address,
      );
      
      _wallet = WalletConnection(
        address: address,
        balance: '0.0',
        isConnected: true,
        networkName: ShardeumNetwork.name,
        chainId: ShardeumNetwork.chainId,
      );
      
      await refreshBalance();
      notifyListeners();
    } catch (e) {
      _setError('Failed to import wallet: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Import wallet from mnemonic
  Future<void> importFromMnemonic(String mnemonic) async {
    _setLoading(true);
    _clearError();
    try {
      if (kDebugMode) print('Starting mnemonic import...');
      final cleanMnemonic = mnemonic.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
      if (cleanMnemonic.isEmpty) throw Exception('Mnemonic phrase cannot be empty');
      final words = cleanMnemonic.split(' ');
      const allowed = {12, 15, 18, 21, 24};
      if (!allowed.contains(words.length)) {
        throw Exception('Mnemonic must be one of: 12, 15, 18, 21 or 24 words (found ${words.length}).');
      }
      final walletData = await _walletService.importFromMnemonic(cleanMnemonic);
      if (walletData['address'] == null || walletData['privateKey'] == null) {
        throw Exception('Failed to derive wallet');
      }
      await _walletService.saveWallet(
        privateKey: walletData['privateKey']!,
        address: walletData['address']!,
        mnemonic: walletData['mnemonic']!,
      );
      _wallet = WalletConnection(
        address: walletData['address']!,
        balance: '0.0',
        isConnected: true,
        networkName: ShardeumNetwork.name,
        chainId: ShardeumNetwork.chainId,
      );
      await refreshBalance();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Mnemonic import failed: $e');
      if (e.toString().contains('one of')) {
        _setError('Please use 12 / 15 / 18 / 21 / 24 word BIP39 mnemonic.');
      } else if (e.toString().contains('Invalid mnemonic')) {
        _setError('Invalid mnemonic phrase.');
      } else {
        _setError('Failed to import wallet: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Send tip (local wallet only)
  Future<String?> sendTip({
    required String toAddress,
    required String amount,
    String message = '',
  }) async {
    _setLoading(true);
    _clearError();
    try {
      if (!_blockchainService.isValidAddress(toAddress)) {
        throw Exception('Invalid recipient address');
      }
      if (toAddress.toLowerCase() == _wallet.address.toLowerCase()) {
        throw Exception('Cannot send tip to yourself');
      }
      final privateKey = await _walletService.getPrivateKey();
      if (privateKey == null) throw Exception('No wallet found. Import or create first.');
      final txHash = await _blockchainService.sendTip(
        privateKey: privateKey,
        toAddress: toAddress,
        amount: amount,
        message: message,
      );
      final tip = Tip(
        from: _wallet.address,
        to: toAddress,
        amount: amount,
        message: message,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        transactionHash: txHash,
      );
      _sentTips.insert(0, tip);
      await refreshBalance();
      notifyListeners();
      return txHash;
    } catch (e) {
      _setError('Failed to send tip: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh wallet balance
  Future<void> refreshBalance() async {
    if (!_wallet.isConnected) return;
    
    try {
      final updatedWallet = await _walletService.refreshConnection(_wallet.address);
      if (updatedWallet != null) {
        _wallet = updatedWallet;
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing balance: $e');
    }
  }

  // Get stored mnemonic
  Future<String?> getMnemonic() async {
    return await _walletService.getMnemonic();
  }

  // Disconnect wallet
  Future<void> disconnect() async {
    await _walletService.clearWallet();
    _wallet = WalletConnection.disconnected();
    _sentTips.clear();
    _receivedTips.clear();
    _clearError();
    notifyListeners();
  }

  // Verify address
  Future<Map<String, dynamic>?> verifyAddress(String address) async {
    try {
      return await _blockchainService.verifyAddress(address);
    } catch (e) {
      _setError('Failed to verify address: $e');
      return null;
    }
  }

  // Generate QR code for receiving
  String generateReceiveQR({String? amount, String? message}) {
    return _blockchainService.generateReceiveQR(
      _wallet.address,
      amount: amount,
      message: message,
    );
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _blockchainService.dispose();
    super.dispose();
  }
}
