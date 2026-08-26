import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../model/bill_model.dart';
import '../model/bill_item_model.dart';
import 'billing_state.dart';
import 'cart_provider.dart';
import '../../settings/provider/settings_provider.dart';
import '../../billing_history/provider/billing_history_provider.dart';

final billingModeProvider = StateProvider<BillingMode>((ref) {
  return const BillingMode.create();
});

final billingProcessProvider =
    StateNotifierProvider<BillingNotifier, BillingProcessState>((ref) {
  return BillingNotifier(ref);
});

class BillingNotifier extends StateNotifier<BillingProcessState> {
  final Ref ref;

  BillingNotifier(this.ref) : super(const BillingIdleState());

  void resetState() {
    state = const BillingIdleState();
  }

  Future<void> startEditBill(BillModel bill) async {
    if (bill.id == null) return;
    // 1. Set mode to edit
    ref.read(billingModeProvider.notifier).state = BillingMode.edit(
      billId: bill.id!,
      invoiceNumber: bill.invoiceNumber,
      createdAt: bill.createdAt,
    );

    // 2. Load into cart
    ref.read(cartProvider.notifier).loadFromBill(bill);
    state = const BillingIdleState();
  }

  void cancelEdit() {
    ref.read(billingModeProvider.notifier).state = const BillingMode.create();
    ref.read(cartProvider.notifier).clearCart();
    state = const BillingIdleState();
  }

  Future<bool> processBill() async {
    final cart = ref.read(cartProvider);
    final mode = ref.read(billingModeProvider);

    if (cart.isEmpty) {
      state = const BillingErrorState('Cannot complete an empty bill. Please add products.');
      return false;
    }

    try {
      state = const BillingSavingState();

      final billingRepo = ref.read(billingRepositoryProvider);
      final pdfService = ref.read(pdfServiceProvider);
      final fileService = ref.read(fileServiceProvider);
      final settingsAsync = ref.read(settingsProvider);
      final settings = settingsAsync.valueOrNull ??
          await ref.read(settingsRepositoryProvider).getSettings();

      final now = DateTime.now();
      String invoiceNumber;
      DateTime createdAt;
      DateTime? updatedAt;

      if (mode.isEdit) {
        invoiceNumber = mode.invoiceNumber!;
        createdAt = mode.createdAt!;
        updatedAt = now;
      } else {
        invoiceNumber = await billingRepo.generateNextInvoiceNumber(now);
        createdAt = now;
        updatedAt = null;
      }

      // Prepare Bill Model
      final billToSave = BillModel(
        id: mode.isEdit ? mode.billId : null,
        invoiceNumber: invoiceNumber,
        customerName: cart.customerName.trim().isNotEmpty ? cart.customerName.trim() : null,
        customerPhone: cart.customerPhone.trim().isNotEmpty ? cart.customerPhone.trim() : null,
        subtotal: cart.subtotal,
        discountPercent: cart.discountPercent,
        discountAmount: cart.effectiveDiscountAmount,
        taxPercent: cart.taxEnabled ? cart.taxPercent : 0.0,
        taxAmount: cart.taxAmount,
        totalAmount: cart.payableTotal,
        isTotalEdited: cart.isTotalEdited,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Prepare Items snapshot
      final itemsToSave = cart.items.map((item) {
        return BillItemModel(
          productName: item.productName,
          unitPrice: item.unitPrice,
          quantity: item.quantity,
          totalPrice: item.totalPrice,
        );
      }).toList();

      // Save to SQLite inside transaction
      BillModel savedBill;
      if (mode.isEdit) {
        savedBill = await billingRepo.updateBill(billToSave, itemsToSave);
      } else {
        savedBill = await billingRepo.createBill(billToSave, itemsToSave);
      }

      // State: Generating PDF
      state = const BillingGeneratingPdfState();

      File? pdfFile;
      try {
        final pdfBytes = await pdfService.generateInvoicePdf(
          bill: savedBill,
          settings: settings,
        );
        pdfFile = await fileService.saveInvoicePdf(
          invoiceNumber: savedBill.invoiceNumber,
          bytes: pdfBytes,
        );
      } catch (e) {
        // PDF generation error should be logged, but bill is securely saved in DB
        // ignore: avoid_print
        print('Error generating or saving PDF: $e');
      }

      // Refresh billing history
      ref.invalidate(billingHistoryListProvider);

      // Clear cart & reset mode
      ref.read(cartProvider.notifier).clearCart();
      ref.read(billingModeProvider.notifier).state = const BillingMode.create();

      state = BillingSuccessState(
        bill: savedBill,
        pdfFile: pdfFile,
        isEdit: mode.isEdit,
      );
      return true;
    } catch (e) {
      state = BillingErrorState('Failed to process bill: ${e.toString()}');
      return false;
    }
  }
}
