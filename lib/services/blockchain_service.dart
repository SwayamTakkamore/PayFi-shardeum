import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import '../models/wallet.dart';
import '../models/tip.dart';

class BlockchainService {
  static const String _rpcUrl = ShardeumNetwork.rpcUrl;
  late Web3Client _client;
  
  // Smart Contract details (will be updated after deployment)
  static const String _contractAddress = '0x...'; // Update with deployed contract address
  static const String _contractAbi = '''[
    {
      "inputs": [
        {"internalType": "address", "name": "_to", "type": "address"},
        {"internalType": "string", "name": "_message", "type": "string"}
      ],
      "name": "sendTip",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "address", "name": "_user", "type": "address"}
      ],
      "name": "getTipsSent",
      "outputs": [
        {
          "components": [
            {"internalType": "address", "name": "from", "type": "address"},
            {"internalType": "address", "name": "to", "type": "address"},
            {"internalType": "uint256", "name": "amount", "type": "uint256"},
            {"internalType": "string", "name": "message", "type": "string"},
            {"internalType": "uint256", "name": "timestamp", "type": "uint256"}
          ],
          "internalType": "struct TipJar.Tip[]",
          "name": "",
          "type": "tuple[]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {"internalType": "address", "name": "_user", "type": "address"}
      ],
      "name": "getTipsReceived",
      "outputs": [
        {
          "components": [
            {"internalType": "address", "name": "from", "type": "address"},
            {"internalType": "address", "name": "to", "type": "address"},
            {"internalType": "uint256", "name": "amount", "type": "uint256"},
            {"internalType": "string", "name": "message", "type": "string"},
            {"internalType": "uint256", "name": "timestamp", "type": "uint256"}
          ],
          "internalType": "struct TipJar.Tip[]",
          "name": "",
          "type": "tuple[]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "anonymous": false,
      "inputs": [
        {"indexed": true, "internalType": "address", "name": "from", "type": "address"},
        {"indexed": true, "internalType": "address", "name": "to", "type": "address"},
        {"indexed": false, "internalType": "uint256", "name": "amount", "type": "uint256"},
        {"indexed": false, "internalType": "string", "name": "message", "type": "string"},
        {"indexed": false, "internalType": "uint256", "name": "timestamp", "type": "uint256"}
      ],
      "name": "TipSent",
      "type": "event"
    }
  ]''';

  BlockchainService() {
    _client = Web3Client(_rpcUrl, http.Client());
  }

  // Get wallet balance
  Future<String> getBalance(String address) async {
    try {
      final balance = await _client.getBalance(EthereumAddress.fromHex(address));
      return EtherAmount.inWei(balance.getInWei).getValueInUnit(EtherUnit.ether).toString();
    } catch (e) {
      print('Error getting balance: $e');
      return '0.0';
    }
  }

  // Get network chain ID
  Future<int> getChainId() async {
    try {
      final chainId = await _client.getChainId();
      return chainId.toInt();
    } catch (e) {
      print('Error getting chain ID: $e');
      return 0;
    }
  }

  // Send simple tip transaction (without smart contract for now)
  Future<String?> sendTip({
    required String privateKey,
    required String toAddress,
    required String amount,
    String message = '',
  }) async {
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      final from = await credentials.extractAddress();
      final to = EthereumAddress.fromHex(toAddress);
      final value = EtherAmount.fromUnitAndValue(EtherUnit.ether, amount);

      final transaction = Transaction(
        to: to,
        value: value,
        gasPrice: EtherAmount.inWei(BigInt.from(2000000000)), // 2 gwei
      );

      final txHash = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: ShardeumNetwork.chainId,
      );

      return txHash;
    } catch (e) {
      print('Error sending tip: $e');
      throw Exception('Failed to send tip: $e');
    }
  }

  // Get transaction details
  Future<TransactionInformation?> getTransaction(String txHash) async {
    try {
      return await _client.getTransactionByHash(txHash);
    } catch (e) {
      print('Error getting transaction: $e');
      return null;
    }
  }

  // Verify address has activity (for verification API)
  Future<Map<String, dynamic>> verifyAddress(String address) async {
    try {
      final txCount = await _client.getTransactionCount(
        EthereumAddress.fromHex(address),
      );
      final balance = await getBalance(address);

      return {
        'address': address,
        'hasSentTips': txCount > 0,
        'transactionCount': txCount,
        'balance': balance,
        'verified': txCount > 0,
        'method': 'transaction_count_verification',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error verifying address: $e');
      return {
        'address': address,
        'verified': false,
        'error': e.toString(),
      };
    }
  }

  // Validate Ethereum address
  bool isValidAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Generate QR code data for receiving tips
  String generateReceiveQR(String address, {String? amount, String? message}) {
    String qrData = 'ethereum:$address';
    List<String> params = [];
    
    if (amount != null && amount.isNotEmpty) {
      params.add('value=${EtherAmount.fromUnitAndValue(EtherUnit.ether, amount).getInWei}');
    }
    
    if (message != null && message.isNotEmpty) {
      params.add('message=${Uri.encodeComponent(message)}');
    }
    
    if (params.isNotEmpty) {
      qrData += '?${params.join('&')}';
    }
    
    return qrData;
  }

  void dispose() {
    _client.dispose();
  }
}
