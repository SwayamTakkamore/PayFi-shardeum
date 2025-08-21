import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';

class SendTipScreen extends StatefulWidget {
  const SendTipScreen({super.key});

  @override
  State<SendTipScreen> createState() => _SendTipScreenState();
}

class _SendTipScreenState extends State<SendTipScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Tip'),
        elevation: 0,
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Balance',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${AppUtils.formatCrypto(walletProvider.wallet.balance)} SHM',
                          style: AppTextStyles.headline3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Recipient Address
                  Text(
                    'Recipient Address',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _recipientController,
                    decoration: InputDecoration(
                      hintText: '0x...',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: _scanQRCode,
                            icon: const Icon(Icons.qr_code_scanner),
                            tooltip: 'Scan QR Code',
                          ),
                          IconButton(
                            onPressed: _pasteFromClipboard,
                            icon: const Icon(Icons.paste),
                            tooltip: 'Paste',
                          ),
                        ],
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a recipient address';
                      }
                      if (!AppUtils.isValidEthereumAddress(value)) {
                        return 'Please enter a valid Ethereum address';
                      }
                      if (value.toLowerCase() == walletProvider.wallet.address.toLowerCase()) {
                        return 'You cannot send a tip to yourself';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Amount
                  Text(
                    'Amount (SHM)',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      hintText: '0.0',
                      suffixText: 'SHM',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              _setMaxAmount(walletProvider.wallet.balance);
                            },
                            child: const Text('MAX'),
                          ),
                        ],
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (!AppUtils.isValidAmount(value)) {
                        return 'Please enter a valid amount';
                      }
                      final amount = double.parse(value);
                      final balance = double.parse(walletProvider.wallet.balance);
                      if (amount > balance) {
                        return 'Insufficient balance';
                      }
                      if (amount <= 0) {
                        return 'Amount must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Message (Optional)
                  Text(
                    'Message (Optional)',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Add a message to your tip...',
                    ),
                    maxLines: 3,
                    maxLength: 200,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Transaction Summary
                  if (_amountController.text.isNotEmpty && AppUtils.isValidAmount(_amountController.text))
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction Summary',
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildSummaryRow('Amount', '${_amountController.text} SHM'),
                          _buildSummaryRow('Network Fee', '~0.001 SHM'),
                          const Divider(),
                          _buildSummaryRow(
                            'Total',
                            '${(double.parse(_amountController.text) + 0.001).toStringAsFixed(4)} SHM',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  
                  if (walletProvider.error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        walletProvider.error!,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Send Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: walletProvider.isLoading ? null : _sendTip,
                      child: walletProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Send Tip'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _scanQRCode() {
    // TODO: Implement QR code scanning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR code scanning coming soon!'),
      ),
    );
  }

  void _pasteFromClipboard() async {
    // TODO: Implement clipboard paste
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Clipboard paste coming soon!'),
      ),
    );
  }

  void _setMaxAmount(String balance) {
    // Set maximum amount minus estimated gas fee
    final maxAmount = double.parse(balance) - 0.001;
    if (maxAmount > 0) {
      _amountController.text = maxAmount.toStringAsFixed(4);
    }
  }

  void _sendTip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final walletProvider = context.read<WalletProvider>();
    
    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    // Send the tip
    final txHash = await walletProvider.sendTip(
      toAddress: _recipientController.text.trim(),
      amount: _amountController.text.trim(),
      message: _messageController.text.trim(),
    );

    if (mounted) {
      if (txHash != null) {
        // Success
        _showSuccessDialog(txHash);
      } else {
        // Error is already shown by the provider
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to send:'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${_amountController.text} SHM',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('To: ${AppUtils.truncateAddress(_recipientController.text)}'),
            if (_messageController.text.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Message: "${_messageController.text}"'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccessDialog(String txHash) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Tip Sent!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your tip has been sent successfully.'),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Transaction Hash:',
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppUtils.truncateAddress(txHash),
              style: AppTextStyles.body2.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Open transaction in explorer
            },
            child: const Text('View on Explorer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
