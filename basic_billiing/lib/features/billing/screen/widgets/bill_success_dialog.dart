import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../model/bill_model.dart';
import '../../provider/billing_provider.dart';

class BillSuccessDialog extends ConsumerStatefulWidget {
  final BillModel bill;
  final bool isEdit;

  const BillSuccessDialog({
    super.key,
    required this.bill,
    required this.isEdit,
  });

  static Future<void> show(BuildContext context, BillModel bill, bool isEdit) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BillSuccessDialog(bill: bill, isEdit: isEdit),
    );
  }

  @override
  ConsumerState<BillSuccessDialog> createState() => _BillSuccessDialogState();
}

class _BillSuccessDialogState extends ConsumerState<BillSuccessDialog> {
  bool _isOpeningPdf = false;

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final isEdit = widget.isEdit;

    return AppDialog(
      title: isEdit
          ? 'Bill Updated Successfully'
          : 'Bill Completed Successfully',
      maxWidth: 480,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 36,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.invoiceNumber,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total: ${CurrencyUtils.format(bill.totalAmount)}  •  ${bill.paymentType.toUpperCase()}  •  ${bill.items.length} items',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Invoice has been generated and saved to your Documents/BillingApp/Invoices directory.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Open PDF',
          icon: Icons.picture_as_pdf,
          isLoading: _isOpeningPdf,
          variant: AppButtonVariant.primary,
          onPressed: _isOpeningPdf
              ? null
              : () async {
                  setState(() => _isOpeningPdf = true);
                  try {
                    final fileService = ref.read(fileServiceProvider);
                    final opened = await fileService.openInvoicePdf(
                      bill.invoiceNumber,
                    );
                    if (!opened && context.mounted) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     content:
                      //         Text('Could not open PDF with default viewer'),
                      //   ),
                      // );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error opening PDF: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isOpeningPdf = false);
                    }
                  }
                },
        ),
        AppButton(
          label: 'Done',
          variant: AppButtonVariant.outline,
          onPressed: () {
            ref.read(billingProcessProvider.notifier).resetState();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
