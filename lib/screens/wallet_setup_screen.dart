import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../utils/theme.dart';
import 'home_screen.dart';

class WalletSetupScreen extends StatefulWidget {
  const WalletSetupScreen({super.key});

  @override
  State<WalletSetupScreen> createState() => _WalletSetupScreenState();
}

class _WalletSetupScreenState extends State<WalletSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
          children: [
            _buildWelcomePage(),
            _buildCreateWalletPage(),
            _buildImportWalletPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Title
          const Text(
            'Welcome to PayFi Tip Jar',
            style: AppTextStyles.headline1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          // Subtitle
          Text(
            'Send and receive SHM tips on Shardeum Testnet with ease',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Features
          _buildFeatureItem(
            Icons.security,
            'Secure',
            'Your private keys are stored securely on your device',
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildFeatureItem(
            Icons.speed,
            'Fast & Cheap',
            'Low-cost transactions on Shardeum network',
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildFeatureItem(
            Icons.verified,
            'Verifiable',
            'All transactions are verifiable on-chain',
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Get Started Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateWalletPage() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom - 48,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text('Create New Wallet', style: AppTextStyles.headline2),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Generate a new wallet or import an existing one using a private key or a 12 / 15 / 18 / 21 / 24 word mnemonic phrase.',
                      style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Backup tips:\n• Write the mnemonic on paper (offline)\n• Never share it or your private key\n• Losing it means losing access\n• Use import to recover later',
                        style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: walletProvider.isLoading
                            ? null
                            : () async {
                                await walletProvider.generateWallet();
                                if (walletProvider.hasWallet && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Wallet created successfully!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  // Navigate back to home screen
                                  if (mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                                      (route) => false,
                                    );
                                  }
                                }
                              },
                        child: walletProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Create Wallet'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Import Existing Wallet'),
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
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Text(
                          walletProvider.error!,
                          style: AppTextStyles.body2.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImportWalletPage() {
    final TextEditingController privateKeyController = TextEditingController();
    final TextEditingController mnemonicController = TextEditingController();
    bool usePrivateKey = true;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('Import Wallet', style: AppTextStyles.headline2),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Import using a private key or a BIP39 mnemonic (12 / 15 / 18 / 21 / 24 words).',
                    style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => usePrivateKey = true),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: usePrivateKey ? AppColors.primary.withOpacity(0.1) : null,
                          ),
                          child: Text(
                            'Private Key',
                            style: TextStyle(
                              color: usePrivateKey ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => usePrivateKey = false),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: !usePrivateKey ? AppColors.primary.withOpacity(0.1) : null,
                          ),
                          child: Text(
                            'Mnemonic',
                            style: TextStyle(
                              color: !usePrivateKey ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (usePrivateKey) ...[
                    const Text('Private Key', style: AppTextStyles.body1),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: privateKeyController,
                      decoration: const InputDecoration(
                        hintText: 'Enter 64 hex characters (without 0x)',
                      ),
                      obscureText: true,
                    ),
                  ] else ...[
                    const Text('Mnemonic Phrase', style: AppTextStyles.body1),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: mnemonicController,
                      decoration: const InputDecoration(
                        hintText: 'Enter 12 / 15 / 18 / 21 / 24 words',
                      ),
                      maxLines: 3,
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: walletProvider.isLoading
                          ? null
                          : () async {
                              try {
                                if (usePrivateKey) {
                                  final pk = privateKeyController.text.trim();
                                  if (pk.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Enter private key'), backgroundColor: AppColors.error),
                                    );
                                    return;
                                  }
                                  await walletProvider.importFromPrivateKey(pk);
                                } else {
                                  final phrase = mnemonicController.text.trim();
                                  if (phrase.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Enter mnemonic phrase'), backgroundColor: AppColors.error),
                                    );
                                    return;
                                  }
                                  await walletProvider.importFromMnemonic(phrase);
                                }
                                if (walletProvider.hasWallet && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Wallet imported successfully!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  // Navigate back to home screen
                                  if (mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                                      (route) => false,
                                    );
                                  }
                                }
                              } catch (_) {}
                            },
                      child: walletProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Import Wallet'),
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
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Text(
                        walletProvider.error!,
                        style: AppTextStyles.body2.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTextStyles.body2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
