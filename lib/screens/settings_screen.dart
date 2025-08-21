import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Wallet Information Section
              _buildSection(
                'Wallet Information',
                [
                  _buildInfoTile(
                    'Address',
                    walletProvider.wallet.shortAddress,
                    onTap: () async {
                      await AppUtils.copyToClipboard(walletProvider.wallet.address);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Address copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    trailing: const Icon(Icons.copy, size: 16),
                  ),
                  _buildInfoTile(
                    'Balance',
                    walletProvider.wallet.formattedBalance,
                  ),
                  _buildInfoTile(
                    'Network',
                    walletProvider.wallet.networkName,
                    trailing: Icon(
                      walletProvider.wallet.isOnShardeumNetwork
                          ? Icons.check_circle
                          : Icons.error,
                      color: walletProvider.wallet.isOnShardeumNetwork
                          ? AppColors.success
                          : AppColors.error,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Security Section
              _buildSection(
                'Security',
                [
                  _buildActionTile(
                    'Backup Wallet',
                    'View your mnemonic phrase',
                    Icons.backup,
                    onTap: () => _showBackupDialog(context, walletProvider),
                  ),
                  _buildActionTile(
                    'Export Private Key',
                    'Export your private key',
                    Icons.key,
                    onTap: () => _showPrivateKeyDialog(context, walletProvider),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Network Section
              _buildSection(
                'Network',
                [
                  _buildInfoTile(
                    'RPC URL',
                    'api-testnet.shardeum.org',
                  ),
                  _buildInfoTile(
                    'Chain ID',
                    '8083',
                  ),
                  _buildActionTile(
                    'Block Explorer',
                    'View on Shardeum Explorer',
                    Icons.open_in_browser,
                    onTap: () {
                      // TODO: Open block explorer
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening block explorer...'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // App Information Section
              _buildSection(
                'App Information',
                [
                  _buildInfoTile(
                    'Version',
                    '1.0.0',
                  ),
                  _buildActionTile(
                    'About',
                    'Learn more about PayFi Tip Jar',
                    Icons.info,
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Danger Zone
              _buildSection(
                'Danger Zone',
                [
                  _buildActionTile(
                    'Disconnect Wallet',
                    'Remove wallet from this device',
                    Icons.logout,
                    onTap: () => _showDisconnectDialog(context, walletProvider),
                    isDestructive: true,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            title,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          elevation: 1,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    String title,
    String subtitle, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.body1,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.body2.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.body1.copyWith(
          color: isDestructive ? AppColors.error : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.body2.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showBackupDialog(BuildContext context, WalletProvider walletProvider) async {
    final mnemonic = await walletProvider.getMnemonic();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Backup Wallet'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your mnemonic phrase is the key to your wallet. Keep it safe and never share it with anyone.',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: AppSpacing.md),
            if (mnemonic != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mnemonic,
                  style: AppTextStyles.body2.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ] else ...[
              const Text(
                'Mnemonic phrase not available (wallet was imported with private key)',
                style: AppTextStyles.body2,
              ),
            ],
          ],
        ),
        actions: [
          if (mnemonic != null)
            TextButton(
              onPressed: () async {
                await AppUtils.copyToClipboard(mnemonic);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mnemonic copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Copy'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivateKeyDialog(BuildContext context, WalletProvider walletProvider) async {
    // Show warning first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Warning'),
          ],
        ),
        content: const Text(
          'Your private key gives full access to your wallet. Never share it with anyone and ensure you\'re in a secure environment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Show Private Key'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final privateKey = await walletProvider.getMnemonic(); // This should get private key
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Private Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (privateKey != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  privateKey,
                  style: AppTextStyles.body2.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ] else ...[
              const Text('Private key not available'),
            ],
          ],
        ),
        actions: [
          if (privateKey != null)
            TextButton(
              onPressed: () async {
                await AppUtils.copyToClipboard(privateKey);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Private key copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Copy'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context, WalletProvider walletProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Wallet'),
        content: const Text(
          'Are you sure you want to disconnect your wallet? Make sure you have backed up your mnemonic phrase or private key.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await walletProvider.disconnect();
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to home
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About PayFi Tip Jar'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PayFi Tip Jar is a decentralized tipping application built for the Shardeum blockchain.',
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Features:',
              style: AppTextStyles.body1,
            ),
            Text('• Send and receive SHM tips'),
            Text('• QR code support'),
            Text('• Low transaction fees'),
            Text('• Verifiable on-chain transactions'),
            SizedBox(height: AppSpacing.md),
            Text(
              'Built with Flutter for mobile and Web3Dart for blockchain integration.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
