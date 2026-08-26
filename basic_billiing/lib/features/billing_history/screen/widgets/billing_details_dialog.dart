import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../billing/model/bill_model.dart';
import '../../../billing/provider/billing_provider.dart';
import '../../provider/billing_history_provider.dart';
import 'delete_bill_dialog.dart';

class BillingDetailsDialog extends ConsumerStatefulWidget {
  final int billId;
  final VoidCallback? onNavigateToBilling;

  const BillingDetailsDialog({
    super.key,
    required this.billId,
    this.onNavigateToBilling,
  });

  static Future<void> show(
    BuildContext context, {
    required int billId,
    VoidCallback? onNavigateToBilling,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => BillingDetailsDialog(
        billId: billId,
        onNavigateToBilling: onNavigateToBilling,
      ),
    );
  }

  @override
  ConsumerState<BillingDetailsDialog> createState() =>
      _BillingDetailsDialogState();
}

class _BillingDetailsDialogState extends ConsumerState<BillingDetailsDialog> {
  BillModel? _bill;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bill = await ref
          .read(billingHistoryListProvider.notifier)
          .getBillDetails(widget.billId);
      if (mounted) {
        setState(() {
          _bill = bill;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load bill details: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: LoadingWidget(message: 'Loading invoice details...'),
        ),
      );
    }

    if (_error != null || _bill == null) {
      return AppDialog(
        title: 'Error',
        content: Text(_error ?? 'Bill not found'),
        actions: [
          AppButton(
            label: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    final bill = _bill!;

    return AppDialog(
      title: 'Invoice ${bill.invoiceNumber}',
      maxWidth: 620,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.customerName?.isNotEmpty == true
                          ? bill.customerName!
                          : 'Walk-in Customer',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (bill.customerPhone?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Phone: ${bill.customerPhone}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppDateUtils.formatInvoiceDate(bill.createdAt),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppDateUtils.formatTime(bill.createdAt),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Items Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Item',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Price',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Items List
          ...bill.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      item.productName,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      CurrencyUtils.format(item.unitPrice),
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      CurrencyUtils.format(item.totalPrice),
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),

          // Financial Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _buildSummaryLine(
                  'Subtotal',
                  CurrencyUtils.format(bill.subtotal),
                ),
                if (bill.discountAmount > 0)
                  _buildSummaryLine(
                    'Discount',
                    '- ${CurrencyUtils.format(bill.discountAmount)}',
                    color: AppColors.error,
                  ),
                if (bill.taxPercent > 0 || bill.taxAmount > 0)
                  _buildSummaryLine(
                    'Tax (${CurrencyUtils.formatPlain(bill.taxPercent)}%)',
                    '+ ${CurrencyUtils.format(bill.taxAmount)}',
                  ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bill.isTotalEdited ? 'Total (Edited)' : 'Total Amount',
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      CurrencyUtils.format(bill.totalAmount),
                      style: AppTextStyles.billingTotalSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Delete',
          icon: Icons.delete_outline,
          variant: AppButtonVariant.danger,
          onPressed: () async {
            final deleted = await DeleteBillDialog.show(context, bill);
            if (deleted == true && context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        AppButton(
          label: 'Edit Bill',
          icon: Icons.edit,
          variant: AppButtonVariant.outline,
          onPressed: () {
            ref.read(billingProcessProvider.notifier).startEditBill(bill);
            Navigator.of(context).pop();
            widget.onNavigateToBilling?.call();
          },
        ),
        AppButton(
          label: 'Open PDF',
          icon: Icons.picture_as_pdf,
          variant: AppButtonVariant.primary,
          onPressed: () async {
            final fileService = ref.read(fileServiceProvider);
            var file = await fileService.getInvoicePdf(bill.invoiceNumber);
            if (file == null || !await file.exists()) {
              // Generate and save if not exists
              final settings = await ref
                  .read(settingsRepositoryProvider)
                  .getSettings();
              final pdfService = ref.read(pdfServiceProvider);
              final bytes = await pdfService.generateInvoicePdf(
                bill: bill,
                settings: settings,
              );
              await fileService.saveInvoicePdf(
                invoiceNumber: bill.invoiceNumber,
                bytes: bytes,
              );
            }
            final opened = await fileService.openInvoicePdf(bill.invoiceNumber);
            if (!opened && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not open PDF with default viewer'),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSummaryLine(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
