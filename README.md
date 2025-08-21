# PayFi Tip Jar - Flutter Mobile App

A Flutter mobile application for the PayFi Tip Jar decentralized tipping system on Shardeum blockchain.

## 🚀 Features

- **Wallet Management**: Create new wallets or import existing ones via private key or mnemonic phrase
- **Send Tips**: Send SHM tokens to any Ethereum address with optional messages
- **Receive Tips**: Generate QR codes for easy tip collection
- **Transaction History**: View sent and received tips
- **Security**: Private keys stored securely on device
- **Network Support**: Built specifically for Shardeum Testnet
- **Real-time Balance**: Auto-updating wallet balance
- **Verification**: Address and transaction verification

## 🛠️ Technical Stack

- **Frontend**: Flutter 3.7+
- **State Management**: Provider pattern
- **Blockchain Integration**: web3dart
- **Storage**: SharedPreferences (secure storage recommended for production)
- **QR Codes**: qr_flutter, qr_code_scanner
- **HTTP Requests**: http package
- **Crypto**: crypto, bip39 packages

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── tip.dart             # Tip data model
│   └── wallet.dart          # Wallet connection model
├── providers/               # State management
│   └── wallet_provider.dart # Main wallet state provider
├── screens/                 # App screens
│   ├── home_screen.dart     # Main dashboard
│   ├── send_tip_screen.dart # Send tips interface
│   ├── receive_screen.dart  # Receive tips/QR code
│   ├── settings_screen.dart # App settings
│   └── wallet_setup_screen.dart # Wallet creation/import
├── services/                # Business logic
│   ├── blockchain_service.dart # Blockchain interactions
│   └── wallet_service.dart  # Wallet management
├── utils/                   # Utilities
│   ├── helpers.dart         # Helper functions
│   └── theme.dart           # App theming
└── widgets/                 # Reusable widgets
    ├── wallet_status_card.dart
    ├── quick_actions.dart
    └── recent_tips.dart
```

## 🔧 Setup Instructions

### Prerequisites

1. **Flutter SDK**: Install Flutter 3.7 or later
2. **Android Studio/VS Code**: With Flutter extensions
3. **Android SDK**: For Android development
4. **Xcode**: For iOS development (macOS only)

### Installation

1. **Navigate to the Flutter app directory**:
   ```bash
   cd Tip-Jar/flutter_tip_jar
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   # For Android
   flutter run

   # For iOS (macOS only)
   flutter run -d ios

   # For web
   flutter run -d chrome
   ```

## 🔗 Blockchain Integration

### Shardeum Testnet Configuration

- **Network Name**: Shardeum Testnet
- **RPC URL**: https://api-testnet.shardeum.org/
- **Chain ID**: 8083
- **Currency**: SHM
- **Explorer**: https://explorer-testnet.shardeum.org/

### Smart Contract Integration

The app is designed to work with the TipJar smart contract deployed on Shardeum. For now, it uses simple ETH transfers, but can be extended to use the smart contract functions.

## 📱 App Features

### Wallet Management
- **Create Wallet**: Generate new wallet with mnemonic phrase
- **Import Wallet**: Import using private key or mnemonic
- **Backup**: Export mnemonic phrase and private key securely
- **Security**: Local storage with encryption recommended

### Tip Functionality
- **Send Tips**: Send SHM to any address with optional message
- **Receive Tips**: Generate QR codes with optional amount/message
- **History**: View transaction history
- **Verification**: Verify addresses and transactions

### User Interface
- **Material Design**: Modern Flutter UI components
- **Responsive**: Works on phones and tablets
- **Accessibility**: Screen reader support

## 🔐 Security Considerations

### Current Implementation
- Private keys stored in SharedPreferences
- Basic input validation
- Network verification

### Production Recommendations
1. **Use Flutter Secure Storage** for private key storage
2. **Implement biometric authentication**
3. **Add PIN/password protection**
4. **Use secure communication (HTTPS)**
5. **Implement proper error handling**
6. **Add transaction signing verification**

## 🚧 Future Enhancements

### Planned Features
1. **Transaction History Screen**: Full transaction history with filtering
2. **Contact Management**: Save frequently used addresses
3. **Multi-language Support**: Internationalization
4. **Push Notifications**: Transaction confirmations
5. **DeFi Integration**: Swap, stake, and other DeFi features
6. **NFT Support**: Send and receive NFTs
7. **WalletConnect Integration**: Connect to dApps

## 📄 License

This project is part of the PayFi Tip Jar application.

---

**Note**: This is a testnet application. Never use real funds or mainnet private keys with this application.
