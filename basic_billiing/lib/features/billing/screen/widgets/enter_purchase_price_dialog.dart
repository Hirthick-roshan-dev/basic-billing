import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../model/cart_item_model.dart';

class PurchaseDetailsResult {
  final Map<String, double> itemPrices;
  final String purchaseShopName;
  final String purchasePaymentType;

  const PurchaseDetailsResult({
    required this.itemPrices,
    required this.purchaseShopName,
    required this.purchasePaymentType,
  });
}

class EnterPurchasePriceDialog extends StatefulWidget {
  final List<CartItemModel> items;
  final double payableTotal;
  final bool isEdit;
  final String initialShopName;
  final String initialPaymentType;

  const EnterPurchasePriceDialog({
    super.key,
    required this.items,
    required this.payableTotal,
    required this.isEdit,
    this.initialShopName = '',
    this.initialPaymentType = 'Cash',
  });

  static Future<PurchaseDetailsResult?> show(
    BuildContext context, {
    required List<CartItemModel> items,
    required double payableTotal,
    required bool isEdit,
    String initialShopName = '',
    String initialPaymentType = 'Cash',
  }) {
    return showDialog<PurchaseDetailsResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EnterPurchasePriceDialog(
        items: items,
        payableTotal: payableTotal,
        isEdit: isEdit,
        initialShopName: initialShopName,
        initialPaymentType: initialPaymentType,
      ),
    );
  }

  @override
  State<EnterPurchasePriceDialog> createState() =>
      _EnterPurchasePriceDialogState();
}

class _EnterPurchasePriceDialogState extends State<EnterPurchasePriceDialog> {
  late final Map<String, TextEditingController> _controllers;
  late final TextEditingController _shopNameController;
  late String _paymentType;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final item in widget.items)
        item.productName: TextEditingController(
          text: item.purchasePrice > 0
              ? CurrencyUtils.formatPlain(item.purchasePrice)
              : '',
        ),
    };
    _shopNameController = TextEditingController(text: widget.initialShopName);
    _paymentType = widget.initialPaymentType.isNotEmpty
        ? widget.initialPaymentType
        : 'Cash';
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _shopNameController.dispose();
    super.dispose();
  }

  double _computeTotalPurchaseCost() {
    double total = 0.0;
    for (final item in widget.items) {
      final text = _controllers[item.productName]?.text.trim() ?? '';
      final price = double.tryParse(text) ?? 0.0;
      total += price * item.quantity;
    }
    return CurrencyUtils.round(total);
  }

  @override
  Widget build(BuildContext context) {
    final totalCost = _computeTotalPurchaseCost();
    final profitOrLoss = CurrencyUtils.round(widget.payableTotal - totalCost);
    final isProfit = profitOrLoss >= 0;

    return AppDialog(
      title: 'Enter Purchase Price (Cost)',
      maxWidth: 580,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Enter product purchase price for store records. This will NOT appear on the customer bill or PDF.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Products table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Product',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Sell Price',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Buy Price (₹)',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Products list
            ...widget.items.map((item) {
              final controller = _controllers[item.productName]!;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Qty: ${item.quantity}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        CurrencyUtils.format(item.unitPrice),
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 38,
                        child: TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            prefixText: '₹ ',
                            hintText: '0.00',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const Divider(height: 24),

            // Vendor & Purchase Payment Mode Section
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
                  const Text(
                    'Purchase Source & Payment Mode',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _shopNameController,
                          decoration: const InputDecoration(
                            labelText: 'Purchase Shop Name',
                            hintText: 'e.g. Metro Spares / Shop name',
                            prefixIcon: Icon(Icons.storefront_outlined, size: 18),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Type',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('Cash'),
                                  selected: _paymentType.toLowerCase() == 'cash',
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _paymentType = 'Cash');
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('GPay'),
                                  selected: _paymentType.toLowerCase() == 'gpay',
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _paymentType = 'GPay');
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Live Profit / Loss Calculation Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isProfit
                    ? AppColors.successLight.withValues(alpha: 0.3)
                    : AppColors.errorLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isProfit
                      ? AppColors.success.withValues(alpha: 0.4)
                      : AppColors.error.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Sold Amount:',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        CurrencyUtils.format(widget.payableTotal),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Purchase Cost:',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        CurrencyUtils.format(totalCost),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isProfit ? 'Estimated Profit:' : 'Estimated Loss:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isProfit
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      Text(
                        '${isProfit ? '+' : ''}${CurrencyUtils.format(profitOrLoss)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isProfit
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: widget.isEdit ? 'Update Bill' : 'Proceed to Complete Bill',
          variant: AppButtonVariant.primary,
          icon: Icons.check,
          onPressed: () {
            final itemPrices = <String, double>{};
            for (final item in widget.items) {
              final text = _controllers[item.productName]?.text.trim() ?? '';
              final val = double.tryParse(text) ?? 0.0;
              itemPrices[item.productName] = CurrencyUtils.round(val);
            }
            Navigator.of(context).pop(
              PurchaseDetailsResult(
                itemPrices: itemPrices,
                purchaseShopName: _shopNameController.text.trim(),
                purchasePaymentType: _paymentType,
              ),
            );
          },
        ),
      ],
    );
  }
}
