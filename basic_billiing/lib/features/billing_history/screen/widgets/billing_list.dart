import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../provider/billing_filter_provider.dart';
import '../../provider/billing_history_provider.dart';
import 'billing_card.dart';

class BillingListWidget extends ConsumerWidget {
  final VoidCallback? onNavigateToBilling;

  const BillingListWidget({super.key, this.onNavigateToBilling});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(billingHistoryListProvider);
    final filter = ref.watch(billingFilterProvider);

    return historyAsync.when(
      loading: () => const LoadingWidget(message: 'Loading billing records...'),
      error: (err, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.red),
            const SizedBox(height: 12),
            Text('Error loading history: $err'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(billingHistoryListProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (bills) {
        if (bills.isEmpty) {
          return EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No invoices found',
            subtitle: filter.type.label == 'All Bills'
                ? 'You haven\'t completed any bills yet. Completed bills will show up here.'
                : 'No bills matched the filter "${filter.type.label}". Try selecting another date range.',
            actionLabel: onNavigateToBilling != null ? 'Create First Bill' : null,
            onAction: onNavigateToBilling,
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(billingHistoryListProvider.notifier).refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: bills.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final bill = bills[index];
              return BillingCard(
                key: ValueKey(bill.id),
                bill: bill,
                onNavigateToBilling: onNavigateToBilling,
              );
            },
          ),
        );
      },
    );
  }
}
