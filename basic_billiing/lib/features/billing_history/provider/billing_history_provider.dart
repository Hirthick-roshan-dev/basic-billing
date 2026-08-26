import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../billing/model/bill_model.dart';
import 'billing_filter_provider.dart';

final billingHistoryListProvider =
    AsyncNotifierProvider<BillingHistoryNotifier, List<BillModel>>(() {
  return BillingHistoryNotifier();
});

class BillingHistoryNotifier extends AsyncNotifier<List<BillModel>> {
  @override
  Future<List<BillModel>> build() async {
    final filter = ref.watch(billingFilterProvider);
    final range = filter.getDateRange();

    final repo = ref.watch(billingHistoryRepositoryProvider);
    return await repo.getBills(
      startDate: range.start,
      endDate: range.end,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteBill(int billId, String invoiceNumber) async {
    final billingRepo = ref.read(billingRepositoryProvider);
    final fileService = ref.read(fileServiceProvider);

    // 1. Delete from SQLite inside transaction
    await billingRepo.deleteBill(billId);

    // 2. Delete associated PDF file
    await fileService.deleteInvoicePdf(invoiceNumber);

    // 3. Refresh history
    ref.invalidateSelf();
  }

  Future<BillModel?> getBillDetails(int billId) async {
    final billingRepo = ref.read(billingRepositoryProvider);
    return await billingRepo.getBillWithItems(billId);
  }
}
