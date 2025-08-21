import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/wallet_status_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_tips.dart';
import '../utils/theme.dart';
import 'send_tip_screen.dart';
import 'receive_screen.dart';
import 'wallet_setup_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh wallet data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().refreshBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.shardeumBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.currency_bitcoin,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'PayFi Tip Jar',
              style: AppTextStyles.headline3,
            ),
          ],
        ),
        actions: [
          Consumer<WalletProvider>(
            builder: (context, walletProvider, child) {
              if (!walletProvider.hasWallet) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          if (!walletProvider.hasWallet) {
            return const WalletSetupScreen();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await walletProvider.refreshBalance();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Network Status
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.shardeumGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.shardeumGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle,
                          color: AppColors.shardeumGreen,
                          size: 12,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Connected to Shardeum Testnet',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.shardeumGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Wallet Status Card
                  const WalletStatusCard(),
                  const SizedBox(height: AppSpacing.lg),

                  // Quick Actions
                  const QuickActions(),
                  const SizedBox(height: AppSpacing.lg),

                  // Recent Tips
                  const RecentTips(),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          if (!walletProvider.hasWallet) {
            return const SizedBox.shrink();
          }
          
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SendTipScreen(),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.send),
            label: const Text('Send Tip'),
          );
        },
      ),
    );
  }
}
