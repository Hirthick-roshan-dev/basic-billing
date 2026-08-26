import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../provider/billing_history_provider.dart';
import 'widgets/billing_history_summary_card.dart';
import 'widgets/billing_list.dart';
import 'widgets/date_filter.dart';

class BillingHistoryScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToBilling;

  const BillingHistoryScreen({super.key, this.onNavigateToBilling});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Billing History', style: AppTextStyles.pageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(billingHistoryListProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DateFilterWidget(),
            const SizedBox(height: 14),
            const BillingHistorySummaryCard(),
            const SizedBox(height: 14),
            Expanded(
              child: BillingListWidget(
                onNavigateToBilling: onNavigateToBilling,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
