import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../models/tip.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';

class RecentTips extends StatelessWidget {
  const RecentTips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        final allTips = [
          ...walletProvider.sentTips,
          ...walletProvider.receivedTips,
        ];
        
        // Sort tips by timestamp (newest first)
        allTips.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Tips',
                  style: AppTextStyles.headline3,
                ),
                if (allTips.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to full history
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Full history coming soon!'),
                        ),
                      );
                    },
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            if (allTips.isEmpty)
              _buildEmptyState()
            else
              _buildTipsList(allTips.take(5).toList(), walletProvider.wallet.address),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No tips yet',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your sent and received tips will appear here',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTipsList(List<Tip> tips, String userAddress) {
    return Column(
      children: tips.map((tip) => _buildTipItem(tip, userAddress)).toList(),
    );
  }

  Widget _buildTipItem(Tip tip, String userAddress) {
    final bool isSent = tip.from.toLowerCase() == userAddress.toLowerCase();
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Status Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSent 
                    ? AppColors.warning.withOpacity(0.1)
                    : AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isSent ? Icons.arrow_upward : Icons.arrow_downward,
                color: isSent ? AppColors.warning : AppColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            
            // Tip Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount and Direction
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${isSent ? '-' : '+'} ${AppUtils.formatCrypto(tip.amount)} SHM',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSent ? AppColors.warning : AppColors.success,
                        ),
                      ),
                      Text(
                        AppUtils.formatRelativeTime(tip.dateTime),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  
                  // Address
                  Text(
                    isSent
                        ? 'To: ${AppUtils.truncateAddress(tip.to)}'
                        : 'From: ${AppUtils.truncateAddress(tip.from)}',
                    style: AppTextStyles.body2,
                  ),
                  
                  // Message (if any)
                  if (tip.message.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      tip.message,
                      style: AppTextStyles.caption.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Action Button
            IconButton(
              onPressed: () {
                _showTipDetails(tip, isSent);
              },
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTipDetails(Tip tip, bool isSent) {
    // TODO: Show tip details modal or navigate to details screen
  }
}
