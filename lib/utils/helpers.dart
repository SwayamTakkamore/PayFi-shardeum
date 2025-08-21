import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AppUtils {
  // Format cryptocurrency amounts
  static String formatCrypto(String amount, {int decimals = 4}) {
    try {
      final value = double.parse(amount);
      return value.toStringAsFixed(decimals);
    } catch (e) {
      return '0.0000';
    }
  }

  // Format fiat currency
  static String formatFiat(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }

  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMM dd, yyyy - HH:mm');
    return formatter.format(dateTime);
  }

  // Format relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Truncate address for display
  static String truncateAddress(String address, {int startChars = 6, int endChars = 4}) {
    if (address.length <= startChars + endChars) return address;
    return '${address.substring(0, startChars)}...${address.substring(address.length - endChars)}';
  }

  // Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Validate Ethereum address format
  static bool isValidEthereumAddress(String address) {
    final regex = RegExp(r'^0x[a-fA-F0-9]{40}$');
    return regex.hasMatch(address);
  }

  // Validate amount input
  static bool isValidAmount(String amount) {
    try {
      final value = double.parse(amount);
      return value > 0;
    } catch (e) {
      return false;
    }
  }

  // Generate blockchain explorer URL
  static String getExplorerUrl(String hash, {bool isTransaction = true}) {
    const baseUrl = 'https://explorer-testnet.shardeum.org';
    if (isTransaction) {
      return '$baseUrl/transaction/$hash';
    } else {
      return '$baseUrl/address/$hash';
    }
  }

  // Copy text to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  // Show snackbar message
  static void showMessage(context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Generate random color for avatar
  static Color generateAvatarColor(String text) {
    final hash = text.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[hash.abs() % colors.length];
  }

  // Convert Wei to Ether
  static String weiToEther(String wei) {
    try {
      final weiValue = BigInt.parse(wei);
      final etherValue = weiValue / BigInt.from(10).pow(18);
      return etherValue.toString();
    } catch (e) {
      return '0';
    }
  }

  // Convert Ether to Wei
  static String etherToWei(String ether) {
    try {
      final etherValue = double.parse(ether);
      final weiValue = (etherValue * 1e18).toStringAsFixed(0);
      return weiValue;
    } catch (e) {
      return '0';
    }
  }
}
