class ShardeumNetwork {
  static const String name = 'Shardeum Testnet';
  static const String rpcUrl = 'https://api-testnet.shardeum.org/';
  static const int chainId = 8083;
  static const String symbol = 'SHM';
  static const String explorerUrl = 'https://explorer-testnet.shardeum.org/';
  static const String faucetUrl = 'https://discord.gg/shardeum';

  static const Map<String, dynamic> networkConfig = {
    'chainId': '0x1F93', // 8083 in hex
    'chainName': name,
    'rpcUrls': [rpcUrl],
    'nativeCurrency': {
      'name': 'Shardeum',
      'symbol': symbol,
      'decimals': 18,
    },
    'blockExplorerUrls': [explorerUrl],
  };
}

enum WalletConnectionType {
  local,        // Generated or imported wallet
  walletConnect, // MetaMask, Trust Wallet, etc.
  webBrowser,   // Browser extension wallets
}

class WalletConnection {
  final String address;
  final String balance;
  final bool isConnected;
  final String networkName;
  final int chainId;
  final WalletConnectionType connectionType;

  WalletConnection({
    required this.address,
    required this.balance,
    required this.isConnected,
    required this.networkName,
    required this.chainId,
    this.connectionType = WalletConnectionType.local,
  });

  factory WalletConnection.disconnected() {
    return WalletConnection(
      address: '',
      balance: '0.0',
      isConnected: false,
      networkName: '',
      chainId: 0,
      connectionType: WalletConnectionType.local,
    );
  }

  String get formattedBalance => '${double.parse(balance).toStringAsFixed(4)} SHM';
  String get shortAddress => address.isNotEmpty 
      ? '${address.substring(0, 6)}...${address.substring(address.length - 4)}'
      : '';
  
  bool get isOnShardeumNetwork => chainId == ShardeumNetwork.chainId;

  bool get isExternalWallet => connectionType != WalletConnectionType.local;

  String get connectionTypeLabel {
    switch (connectionType) {
      case WalletConnectionType.local:
        return 'Local Wallet';
      case WalletConnectionType.walletConnect:
        return 'External Wallet';
      case WalletConnectionType.webBrowser:
        return 'Browser Wallet';
    }
  }
}
