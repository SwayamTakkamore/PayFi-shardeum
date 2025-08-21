import 'package:shared_preferences/shared_preferences.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/web3dart.dart';
import '../models/wallet.dart';
import 'blockchain_service.dart';

class WalletService {
  static const String _privateKeyKey = 'private_key';
  static const String _addressKey = 'wallet_address';
  static const String _mnemonicKey = 'mnemonic_phrase';

  final BlockchainService _blockchainService;

  WalletService(this._blockchainService);

  // Generate new wallet
  Future<Map<String, String>> generateWallet() async {
    // Generate mnemonic
    final mnemonic = bip39.generateMnemonic();

    // Generate private key from mnemonic
    final seed = bip39.mnemonicToSeed(mnemonic);
    final privateKeyBytes = seed.take(32).toList();
    final privateKeyHex = privateKeyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final privateKey = EthPrivateKey.fromHex(privateKeyHex);

    final address = privateKey.address;

    return {
      'mnemonic': mnemonic,
      'privateKey': privateKeyHex,
      'address': address.hex,
    };
  }

  // Import wallet from private key
  Future<String> importFromPrivateKey(String privateKeyHex) async {
    try {
      // Clean the private key (remove 0x prefix if present)
      String cleanPrivateKey = privateKeyHex.startsWith('0x')
          ? privateKeyHex.substring(2)
          : privateKeyHex;

      final privateKey = EthPrivateKey.fromHex(cleanPrivateKey);
      final address = privateKey.address;

      return address.hex;
    } catch (e) {
      throw Exception('Invalid private key: $e');
    }
  }

  // Import wallet from mnemonic
  Future<Map<String, String>> importFromMnemonic(String mnemonic) async {
    try {
      if (!bip39.validateMnemonic(mnemonic)) {
        throw Exception('Invalid mnemonic phrase');
      }

      final seed = bip39.mnemonicToSeed(mnemonic);
      final privateKeyBytes = seed.take(32).toList();
      final privateKeyHex = privateKeyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      final privateKey = EthPrivateKey.fromHex(privateKeyHex);

      final address = privateKey.address;

      return {
        'mnemonic': mnemonic,
        'privateKey': privateKeyHex,
        'address': address.hex,
      };
    } catch (e) {
      throw Exception('Failed to import wallet: $e');
    }
  }

  // Save wallet to secure storage
  Future<void> saveWallet({
    required String privateKey,
    required String address,
    String? mnemonic,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Note: In production, use more secure storage like flutter_secure_storage
    await prefs.setString(_privateKeyKey, privateKey);
    await prefs.setString(_addressKey, address);

    if (mnemonic != null) {
      await prefs.setString(_mnemonicKey, mnemonic);
    }
  }

  // Load wallet from storage
  Future<WalletConnection?> loadWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final privateKey = prefs.getString(_privateKeyKey);
      final address = prefs.getString(_addressKey);

      if (privateKey == null || address == null) {
        return null;
      }

      // Get current balance and network info
      final balance = await _blockchainService.getBalance(address);
      final chainId = await _blockchainService.getChainId();

      return WalletConnection(
        address: address,
        balance: balance,
        isConnected: true,
        networkName: ShardeumNetwork.name,
        chainId: chainId,
      );
    } catch (e) {
      print('Error loading wallet: $e');
      return null;
    }
  }

  // Get stored private key
  Future<String?> getPrivateKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_privateKeyKey);
  }

  // Get stored mnemonic
  Future<String?> getMnemonic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mnemonicKey);
  }

  // Check if wallet exists
  Future<bool> hasWallet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_privateKeyKey) && prefs.containsKey(_addressKey);
  }

  // Clear wallet data (logout)
  Future<void> clearWallet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_privateKeyKey);
    await prefs.remove(_addressKey);
    await prefs.remove(_mnemonicKey);
  }

  // Refresh wallet connection
  Future<WalletConnection?> refreshConnection(String address) async {
    try {
      final balance = await _blockchainService.getBalance(address);
      final chainId = await _blockchainService.getChainId();

      return WalletConnection(
        address: address,
        balance: balance,
        isConnected: true,
        networkName: ShardeumNetwork.name,
        chainId: chainId,
      );
    } catch (e) {
      print('Error refreshing connection: $e');
      return null;
    }
  }
}
