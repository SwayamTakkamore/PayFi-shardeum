import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/wallet.dart';

class WalletConnectService {
  static WalletConnectService? _instance;
  static WalletConnectService get instance {
    _instance ??= WalletConnectService._internal();
    return _instance!;
  }

  WalletConnectService._internal();

  String? _currentAddress;
  bool _isConnected = false;

  // Simple MetaMask connection - shows dialog to enter address
  Future<WalletConnection?> connectWallet() async {
    try {
      // First open MetaMask
      await _launchMetaMask();

      // Return null to indicate we need manual address input
      // The UI will handle showing an address input dialog
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to connect wallet: $e');
      }
      throw Exception('Failed to open MetaMask: $e');
    }
  }

  // Launch MetaMask app
  Future<void> _launchMetaMask() async {
    try {
      final metamaskUri = Uri.parse('metamask://');

      if (await canLaunchUrl(metamaskUri)) {
        await launchUrl(metamaskUri, mode: LaunchMode.externalApplication);
        if (kDebugMode) {
          print('MetaMask launched successfully');
        }
      } else {
        // If MetaMask isn't installed, show appropriate message
        throw Exception('MetaMask not installed. Please install MetaMask and try again.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to launch MetaMask: $e');
      }
      rethrow;
    }
  }

  // Connect with manually entered MetaMask address
  Future<WalletConnection?> connectWithAddress(String address) async {
    try {
      // Validate the address format
      if (!_isValidEthereumAddress(address)) {
        throw Exception('Invalid Ethereum address format');
      }

      _currentAddress = address;
      _isConnected = true;

      return WalletConnection(
        address: address,
        balance: '0.0',
        isConnected: true,
        networkName: 'Shardeum Testnet',
        chainId: 8082,
        connectionType: WalletConnectionType.walletConnect,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to connect with address: $e');
      }
      return null;
    }
  }

  // Send transaction through MetaMask deep link
  Future<String?> sendTransaction({
    required String from,
    required String to,
    required String value,
    String? data,
  }) async {
    try {
      // Treat presence of address as connected
      if (_currentAddress == null) {
        throw Exception('No external wallet address set');
      }

      // Normalize amount: support hex (0x..) or decimal ether string
      BigInt weiAmount;
      if (value.startsWith('0x')) {
        // hex wei
        weiAmount = BigInt.parse(value.substring(2), radix: 16);
      } else {
        // decimal ether -> wei
        final eth = double.tryParse(value);
        if (eth == null) throw Exception('Invalid amount');
        weiAmount = BigInt.from(eth * 1e18);
      }

      final weiHex = '0x' + weiAmount.toRadixString(16);

      // Build multiple param styles for broader MetaMask handling
      final candidates = [
        Uri.parse('metamask://send?address=$to&value=$weiHex'),
        Uri.parse('metamask://send?address=$to&uint256=$weiAmount'),
      ];

      bool launched = false;
      for (final uri in candidates) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      }
      if (!launched) {
        throw Exception('Could not open MetaMask for transaction');
      }

      // Pseudo hash (cannot read actual without WalletConnect v2 session)
      return '0xext_${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}';
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send external tx: $e');
      }
      rethrow;
    }
  }

  // Simple address validation
  bool _isValidEthereumAddress(String address) {
    return RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address);
  }

  // Disconnect
  Future<void> disconnect() async {
    _isConnected = false;
    _currentAddress = null;
  }

  // Check connection status
  bool get isConnected => (_currentAddress != null); // rely on address presence

  // Get connected address
  String? get currentAddress => _currentAddress;

  // Placeholder for signing
  Future<String?> signMessage({
    required String address,
    required String message,
  }) async {
    // Would need more complex implementation for real signing
    return null;
  }

  void dispose() {
    disconnect();
  }
}
