import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../model/cart_item_model.dart';
import '../../provider/cart_provider.dart';

class CartItemWidget extends ConsumerWidget {
  final CartItemModel item;

  const CartItemWidget({super.key, required this.item});

  void _showEditPriceDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: CurrencyUtils.formatPlain(item.unitPrice),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final currentInput = double.tryParse(controller.text.trim()) ?? item.unitPrice;
            final previewTotal = currentInput * item.quantity;

            return AppDialog(
              title: 'Edit Item Price',
              maxWidth: 420,
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quantity: ${item.quantity}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: controller,
                      label: 'Unit Price',
                      hintText: '0.00',
                      prefixText: '${CurrencyUtils.defaultCurrencySymbol} ',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      autofocus: true,
                      validator: Validators.validatePrice,
                      onChanged: (val) {
                        setState(() {});
                      },
                      onSubmitted: (_) {
                        if (formKey.currentState!.validate()) {
                          final newPrice = double.parse(controller.text.trim());
                          ref.read(cartProvider.notifier).updateItemPrice(item.productName, newPrice);
                          Navigator.of(ctx).pop();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total for this item:',
                          style: AppTextStyles.bodySmall,
                        ),
                        Text(
                          CurrencyUtils.format(previewTotal),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Note: Price changes only apply to this bill.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                AppButton(
                  label: 'Apply',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newPrice = double.parse(controller.text.trim());
                      ref.read(cartProvider.notifier).updateItemPrice(item.productName, newPrice);
                      Navigator.of(ctx).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Product name and unit price (clickable to edit)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => _showEditPriceDialog(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${CurrencyUtils.format(item.unitPrice)} each',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.edit_outlined,
                          size: 13,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quantity selector (- QTY +)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  splashRadius: 16,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    ref.read(cartProvider.notifier).decreaseQuantity(item.productName);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${item.quantity}',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  splashRadius: 16,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    ref.read(cartProvider.notifier).increaseQuantity(item.productName);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Total Price
          SizedBox(
            width: 75,
            child: Text(
              CurrencyUtils.format(item.totalPrice),
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Edit Price button
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
            splashRadius: 16,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            tooltip: 'Edit Price',
            onPressed: () => _showEditPriceDialog(context, ref),
          ),

          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
            splashRadius: 16,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            tooltip: 'Remove',
            onPressed: () {
              ref.read(cartProvider.notifier).removeItem(item.productName);
            },
          ),
        ],
      ),
    );
  }
}
