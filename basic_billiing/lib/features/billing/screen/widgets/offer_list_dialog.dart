import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../model/product_model.dart';
import '../../provider/offer_provider.dart';
import '../../provider/product_provider.dart';

class OfferListDialog extends ConsumerStatefulWidget {
  final int offerGroup;

  const OfferListDialog({super.key, this.offerGroup = 1});

  static Future<void> show(BuildContext context, {int offerGroup = 1}) {
    return showDialog(
      context: context,
      builder: (ctx) => OfferListDialog(offerGroup: offerGroup),
    );
  }

  @override
  ConsumerState<OfferListDialog> createState() => _OfferListDialogState();
}

class _OfferListDialogState extends ConsumerState<OfferListDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  ProductModel? _selectedProductToAdd;
  bool _priceInitialized = false;

  @override
  void dispose() {
    _searchController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _savePrice() {
    final parsed = double.tryParse(_priceController.text.trim()) ?? 0.0;
    ref
        .read(offerListFamilyProvider(widget.offerGroup).notifier)
        .setTotalPrice(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final offerAsync = ref.watch(offerListFamilyProvider(widget.offerGroup));
    final offerState =
        offerAsync.valueOrNull ?? OfferGroupState(group: widget.offerGroup);
    final offerList = offerState.products;
    final allProductsAsync = ref.watch(productListProvider);
    final allProducts = allProductsAsync.valueOrNull ?? [];

    if (!_priceInitialized && offerAsync.hasValue) {
      _priceController.text =
          offerState.totalPrice > 0
              ? CurrencyUtils.formatPlain(offerState.totalPrice)
              : '';
      _priceInitialized = true;
    }

    // Filter available products that are NOT already in this offer group
    final availableProducts = allProducts.where((p) {
      return !offerList.any(
        (o) => o.name.toLowerCase().trim() == p.name.toLowerCase().trim(),
      );
    }).toList();

    return AppDialog(
      title: 'Offer ${widget.offerGroup} Configuration (${offerList.length} items)',
      maxWidth: 560,
      content: SizedBox(
        height: 480,
        child: Column(
          children: [
            // Package Total Price Configuration Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Offer Package Total Amount',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Items will add at ₹0.00 and cart total will be set to this amount.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 110,
                    child: TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        prefixText: '₹ ',
                        hintText: '0.00',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      onChanged: (_) => _savePrice(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Quick Add Product to Offer Row
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Autocomplete<ProductModel>(
                      displayStringForOption: (option) =>
                          '${option.name} (${CurrencyUtils.format(option.price)})',
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return availableProducts.take(6);
                        }
                        return availableProducts.where((p) => p.name
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (selection) {
                        setState(() {
                          _selectedProductToAdd = selection;
                        });
                      },
                      fieldViewBuilder:
                          (context, textController, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: textController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Search product to add to Offer ${widget.offerGroup}...',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            suffixIcon: textController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () {
                                      textController.clear();
                                      setState(() {
                                        _selectedProductToAdd = null;
                                      });
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _selectedProductToAdd == null
                        ? null
                        : () async {
                            final product = _selectedProductToAdd!;
                            await ref
                                .read(
                                  offerListFamilyProvider(widget.offerGroup)
                                      .notifier,
                                )
                                .addOffer(product);
                            setState(() {
                              _selectedProductToAdd = null;
                            });
                          },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Products in Offer List
            Expanded(
              child: offerAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text(
                    'Error loading offer products: $err',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
                data: (state) {
                  final products = state.products;
                  if (products.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight
                                    .withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_offer_outlined,
                                size: 36,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No products in Offer ${widget.offerGroup}',
                              style: AppTextStyles.subsectionTitle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Use the search box above or click the offer tag icon on products in the catalog to add items to Offer ${widget.offerGroup}.',
                              style: AppTextStyles.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight
                                .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              product.name.isNotEmpty
                                  ? product.name[0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              'Bill Price: ₹0.00',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(Catalog: ${CurrencyUtils.format(product.price)})',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.error,
                            size: 22,
                          ),
                          tooltip: 'Remove from Offer ${widget.offerGroup}',
                          onPressed: () async {
                            await ref
                                .read(
                                  offerListFamilyProvider(widget.offerGroup)
                                      .notifier,
                                )
                                .removeOffer(product);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (offerList.isNotEmpty)
          AppButton(
            label:
                offerState.totalPrice > 0
                    ? 'Add to Cart (${CurrencyUtils.format(offerState.totalPrice)})'
                    : 'Add All to Cart (${offerList.length} items)',
            icon: Icons.add_shopping_cart,
            variant: AppButtonVariant.primary,
            onPressed: () {
              _savePrice();
              ref
                  .read(
                    offerListFamilyProvider(widget.offerGroup).notifier,
                  )
                  .addAllOffersToCart();
              Navigator.of(context).pop();
            },
          ),
        AppButton(
          label: 'Close',
          variant: AppButtonVariant.outline,
          onPressed: () {
            _savePrice();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
