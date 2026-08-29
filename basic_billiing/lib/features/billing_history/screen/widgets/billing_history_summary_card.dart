import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../provider/billing_history_provider.dart';

class BillingHistorySummaryCard extends ConsumerWidget {
  const BillingHistorySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(billingHistoryListProvider);

    final bills = historyAsync.valueOrNull ?? [];
    final billCount = bills.length;
    final totalAmount = bills.fold<double>(
      0.0,
      (sum, b) => sum + b.totalAmount,
    );
    final totalCashAmount = bills
        .where((b) => b.paymentType.toLowerCase() == 'cash')
        .fold<double>(0.0, (sum, b) => sum + b.totalAmount);
    final totalUpiAmount = bills
        .where((b) => b.paymentType.toLowerCase() == 'upi')
        .fold<double>(0.0, (sum, b) => sum + b.totalAmount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 700;

          if (isCompact) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        icon: Icons.receipt_long_outlined,
                        iconBgColor: AppColors.primaryLight.withValues(alpha: 0.4),
                        iconColor: AppColors.primary,
                        label: 'TOTAL BILLS',
                        value: '$billCount ${billCount == 1 ? 'Bill' : 'Bills'}',
                        valueColor: AppColors.textPrimary,
                      ),
                    ),
                    _buildVerticalDivider(),
                    Expanded(
                      child: _buildMetricItem(
                        icon: Icons.account_balance_wallet_outlined,
                        iconBgColor: Colors.blue.withValues(alpha: 0.12),
                        iconColor: Colors.blue.shade700,
                        label: 'TOTAL AMOUNT',
                        value: CurrencyUtils.format(totalAmount),
                        valueColor: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        icon: Icons.payments_outlined,
                        iconBgColor: AppColors.successLight,
                        iconColor: AppColors.success,
                        label: 'TOTAL CASH',
                        value: CurrencyUtils.format(totalCashAmount),
                        valueColor: AppColors.success,
                      ),
                    ),
                    _buildVerticalDivider(),
                    Expanded(
                      child: _buildMetricItem(
                        icon: Icons.qr_code_2_outlined,
                        iconBgColor: Colors.deepPurple.withValues(alpha: 0.12),
                        iconColor: Colors.deepPurple.shade700,
                        label: 'TOTAL UPI',
                        value: CurrencyUtils.format(totalUpiAmount),
                        valueColor: Colors.deepPurple.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              // Total Bills
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.receipt_long_outlined,
                  iconBgColor: AppColors.primaryLight.withValues(alpha: 0.4),
                  iconColor: AppColors.primary,
                  label: 'TOTAL BILLS',
                  value: '$billCount ${billCount == 1 ? 'Bill' : 'Bills'}',
                  valueColor: AppColors.textPrimary,
                ),
              ),
              _buildVerticalDivider(),

              // Total Amount
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.account_balance_wallet_outlined,
                  iconBgColor: Colors.blue.withValues(alpha: 0.12),
                  iconColor: Colors.blue.shade700,
                  label: 'TOTAL AMOUNT',
                  value: CurrencyUtils.format(totalAmount),
                  valueColor: Colors.blue.shade800,
                ),
              ),
              _buildVerticalDivider(),

              // Total Cash
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.payments_outlined,
                  iconBgColor: AppColors.successLight,
                  iconColor: AppColors.success,
                  label: 'TOTAL CASH',
                  value: CurrencyUtils.format(totalCashAmount),
                  valueColor: AppColors.success,
                ),
              ),
              _buildVerticalDivider(),

              // Total UPI
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.qr_code_2_outlined,
                  iconBgColor: Colors.deepPurple.withValues(alpha: 0.12),
                  iconColor: Colors.deepPurple.shade700,
                  label: 'TOTAL UPI',
                  value: CurrencyUtils.format(totalUpiAmount),
                  valueColor: Colors.deepPurple.shade700,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 38,
      width: 1,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
