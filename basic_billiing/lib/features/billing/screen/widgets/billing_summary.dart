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
import '../../provider/cart_provider.dart';

class BillingSummary extends ConsumerStatefulWidget {
  const BillingSummary({super.key});

  @override
  ConsumerState<BillingSummary> createState() => _BillingSummaryState();
}

class _BillingSummaryState extends ConsumerState<BillingSummary> {
  late final TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    final cart = ref.read(cartProvider);
    _discountController = TextEditingController(
      text: cart.discountAmount > 0 ? CurrencyUtils.formatPlain(cart.discountAmount) : '',
    );
  }

  @override
  void didUpdateWidget(covariant BillingSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cart = ref.read(cartProvider);
    final currentVal = double.tryParse(_discountController.text) ?? 0.0;
    if (currentVal != cart.discountAmount) {
      _discountController.text = cart.discountAmount > 0 ? CurrencyUtils.formatPlain(cart.discountAmount) : '';
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  void _showEditTotalDialog(BuildContext context, CartState cart) {
    final controller = TextEditingController(
      text: CurrencyUtils.formatPlain(cart.payableTotal),
    );

    AppDialog.show(
      context: context,
      title: 'Edit Total Amount',
      maxWidth: 400,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Override the final payable total amount for this bill if necessary. Original calculated breakdown will still be preserved.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: controller,
            label: 'Payable Amount',
            prefixText: '${CurrencyUtils.defaultCurrencySymbol} ',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            autofocus: true,
            validator: Validators.validatePrice,
          ),
          const SizedBox(height: 8),
          Text(
            'Calculated Total: ${CurrencyUtils.format(cart.calculatedTotal)}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
      actions: [
        if (cart.isTotalEdited)
          AppButton(
            label: 'Reset to Default',
            variant: AppButtonVariant.outline,
            onPressed: () {
              ref.read(cartProvider.notifier).resetManualTotal();
              Navigator.of(context).pop();
            },
          ),
        AppButton(
          label: 'Apply',
          onPressed: () {
            final val = double.tryParse(controller.text.trim());
            if (val != null && val >= 0) {
              ref.read(cartProvider.notifier).setManualTotal(val);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    ref.listen<CartState>(cartProvider, (prev, next) {
      if (prev?.discountAmount != next.discountAmount) {
        final currentVal = double.tryParse(_discountController.text) ?? 0.0;
        if (currentVal != next.discountAmount) {
          _discountController.text = next.discountAmount > 0 ? CurrencyUtils.formatPlain(next.discountAmount) : '';
        }
      }
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Subtotal
          _buildRow('Subtotal', CurrencyUtils.format(cart.subtotal)),
          const SizedBox(height: 10),

          // Discount Row (Direct Price Entry)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Discount (Rs)', style: AppTextStyles.bodyMedium),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 85,
                    height: 34,
                    child: TextField(
                      controller: _discountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        fillColor: AppColors.surface,
                        filled: true,
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0.0;
                        ref.read(cartProvider.notifier).setDiscountAmount(parsed);
                      },
                    ),
                  ),
                ],
              ),
              Text(
                cart.effectiveDiscountAmount > 0
                    ? '- ${CurrencyUtils.format(cart.effectiveDiscountAmount)}'
                    : CurrencyUtils.format(0),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: cart.effectiveDiscountAmount > 0 ? AppColors.error : AppColors.textSecondary,
                  fontWeight: cart.effectiveDiscountAmount > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),

          // Tax Row
          if (cart.taxEnabled) ...[
            const SizedBox(height: 10),
            _buildRow(
              'Tax (${CurrencyUtils.formatPlain(cart.taxPercent)}%)',
              '+ ${CurrencyUtils.format(cart.taxAmount)}',
              valueColor: AppColors.textPrimary,
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),

          // Payment Type Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Type', style: AppTextStyles.bodyMedium),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPaymentTypeButton(
                    label: 'Cash',
                    icon: Icons.payments_outlined,
                    isSelected: cart.paymentType.toLowerCase() == 'cash',
                    onTap: () => ref.read(cartProvider.notifier).setPaymentType('Cash'),
                  ),
                  const SizedBox(width: 8),
                  _buildPaymentTypeButton(
                    label: 'UPI',
                    icon: Icons.qr_code_2_outlined,
                    isSelected: cart.paymentType.toLowerCase() == 'upi',
                    onTap: () => ref.read(cartProvider.notifier).setPaymentType('UPI'),
                  ),
                ],
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),

          // Final Payable Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total Payable',
                        style: AppTextStyles.sectionTitle.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (cart.isTotalEdited) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.warning),
                          ),
                          child: Text(
                            'Manual',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (cart.isTotalEdited)
                    Text(
                      'Orig: ${CurrencyUtils.format(cart.calculatedTotal)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  Text(
                    CurrencyUtils.format(cart.payableTotal),
                    style: AppTextStyles.billingTotalSmall.copyWith(
                      color: cart.isTotalEdited ? AppColors.secondaryDark : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: Icon(
                      cart.isTotalEdited ? Icons.restore : Icons.edit_note,
                      size: 22,
                      color: AppColors.primary,
                    ),
                    tooltip: cart.isTotalEdited ? 'Reset edited total' : 'Edit final total',
                    onPressed: () {
                      if (cart.isTotalEdited) {
                        ref.read(cartProvider.notifier).resetManualTotal();
                      } else {
                        _showEditTotalDialog(context, cart);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
