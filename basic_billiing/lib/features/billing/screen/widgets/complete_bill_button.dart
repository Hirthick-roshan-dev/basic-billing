import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../provider/billing_provider.dart';
import '../../provider/billing_state.dart';
import '../../provider/cart_provider.dart';

import 'enter_purchase_price_dialog.dart';

class CompleteBillButton extends ConsumerWidget {
  const CompleteBillButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final mode = ref.watch(billingModeProvider);
    final processState = ref.watch(billingProcessProvider);

    final isLoading =
        processState is BillingSavingState ||
        processState is BillingGeneratingPdfState;

    final buttonLabel = mode.isEdit ? 'Update Bill' : 'Complete Bill';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mode.isEdit) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Editing Invoice #${mode.invoiceNumber}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(billingProcessProvider.notifier).cancelEdit();
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    'Cancel Edit',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
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
              : () async {
                  // Pre-flight check: if job card number entered, ensure it is not duplicate
                  if (cart.jobCardNumber.trim().isNotEmpty) {
                    final exists = await ref
                        .read(billingRepositoryProvider)
                        .isJobCardNumberExists(
                          cart.jobCardNumber.trim(),
                          excludeBillId: mode.isEdit ? mode.billId : null,
                        );
                    if (exists) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Cannot complete bill: Job Card number already exists in another bill.',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                      return;
                    }
                  }

                  if (!context.mounted) return;
                  final details = await EnterPurchasePriceDialog.show(
                    context,
                    items: cart.items,
                    payableTotal: cart.payableTotal,
                    isEdit: mode.isEdit,
                    initialShopName: cart.purchaseShopName,
                    initialPaymentType: cart.purchasePaymentType,
                  );
                  if (details != null) {
                    ref
                        .read(cartProvider.notifier)
                        .setAllPurchasePrices(details.itemPrices);
                    ref
                        .read(cartProvider.notifier)
                        .setPurchaseShopName(details.purchaseShopName);
                    ref
                        .read(cartProvider.notifier)
                        .setPurchasePaymentType(details.purchasePaymentType);
                    ref.read(billingProcessProvider.notifier).processBill();
                  }
                },
          height: 52,
        ),
      ],
    );
  }
}
