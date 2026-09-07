import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../provider/admin_view_provider.dart';

class AdminViewToggleCard extends ConsumerWidget {
  const AdminViewToggleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminView = ref.watch(adminViewProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.admin_panel_settings_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              SizedBox(width: 10),
              Text('Admin View Mode', style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Control visibility of sensitive financial metrics such as Total Sold, Purchase Costs, Net Profits, and item buy prices in Billing History.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin View (Financial & Profit Figures)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAdminView
                            ? 'Enabled — Full profit, cost, and vendor details visible'
                            : 'Disabled — Sensitive metrics are hidden (pass key required to enable)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isAdminView
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isAdminView,
                  activeThumbColor: AppColors.primary,
                  onChanged: (_) {
                    ref.read(adminViewProvider.notifier).toggleAdminView(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
