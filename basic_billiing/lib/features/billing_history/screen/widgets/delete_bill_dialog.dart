import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../billing/model/bill_model.dart';
import '../../provider/billing_history_provider.dart';

class DeleteBillDialog extends ConsumerStatefulWidget {
  final BillModel bill;

  const DeleteBillDialog({super.key, required this.bill});

  static Future<bool?> show(BuildContext context, BillModel bill) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DeleteBillDialog(bill: bill),
    );
  }

  @override
  ConsumerState<DeleteBillDialog> createState() => _DeleteBillDialogState();
}

class _DeleteBillDialogState extends ConsumerState<DeleteBillDialog> {
  bool _isLoading = false;

  Future<void> _handleDelete() async {
    if (widget.bill.id == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(billingHistoryListProvider.notifier).deleteBill(
            widget.bill.id!,
            widget.bill.invoiceNumber,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice ${widget.bill.invoiceNumber} deleted successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting bill: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Delete Bill',
      maxWidth: 420,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to permanently delete invoice "${widget.bill.invoiceNumber}"?',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'This action cannot be undone. All bill items and the saved PDF file will be removed.',
            style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: 'Delete',
          variant: AppButtonVariant.danger,
          isLoading: _isLoading,
          onPressed: _handleDelete,
        ),
      ],
    );
  }
}
