import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../provider/billing_provider.dart';
import '../../provider/billing_state.dart';
import '../../provider/cart_provider.dart';

class CompleteBillButton extends ConsumerWidget {
  const CompleteBillButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final mode = ref.watch(billingModeProvider);
    final processState = ref.watch(billingProcessProvider);

    final isLoading = processState is BillingSavingState ||
        processState is BillingGeneratingPdfState;

    final buttonLabel = mode.isEdit ? 'UPDATE BILL' : 'COMPLETE BILL';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mode.isEdit) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit, size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Editing Invoice: ${mode.invoiceNumber}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(billingProcessProvider.notifier).cancelEdit();
                  },
                  child: const Text('Cancel Edit', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
        AppButton(
          label: isLoading
              ? (processState is BillingGeneratingPdfState
                  ? 'Generating PDF...'
                  : 'Saving Bill...')
              : '$buttonLabel (${CurrencyUtils.format(cart.payableTotal)})',
          icon: mode.isEdit ? Icons.save : Icons.check_circle_outline,
          isLoading: isLoading,
          onPressed: cart.isEmpty
              ? null
              : () {
                  ref.read(billingProcessProvider.notifier).processBill();
                },
          height: 52,
        ),
      ],
    );
  }
}
