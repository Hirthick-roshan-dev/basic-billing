import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../provider/offer_provider.dart';

class OfferListDialog extends ConsumerWidget {
  const OfferListDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const OfferListDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerListProvider);
    final offerList = offerAsync.valueOrNull ?? [];

    return AppDialog(
      title: 'Offer Products List (${offerList.length})',
      maxWidth: 520,
      content: SizedBox(
        height: 380,
        child: offerAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text(
              'Error loading offer products: $err',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
          data: (products) {
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
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_offer_outlined,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No offer products added yet',
                        style: AppTextStyles.subsectionTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Click the offer tag icon on any product in the catalog to add it to this offer list.',
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
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        product.name.isNotEmpty
                            ? product.name[0].toUpperCase()
                            : 'P',
                        style: const TextStyle(
                          fontSize: 16,
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
                  subtitle: Text(
                    CurrencyUtils.format(product.price),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.error,
                      size: 22,
                    ),
                    tooltip: 'Remove from offer list',
                    onPressed: () async {
                      await ref
                          .read(offerListProvider.notifier)
                          .removeOffer(product);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        if (offerList.isNotEmpty)
          AppButton(
            label: 'Add All to Cart (${offerList.length})',
            icon: Icons.add_shopping_cart,
            variant: AppButtonVariant.primary,
            onPressed: () {
              final count = ref
                  .read(offerListProvider.notifier)
                  .addAllOffersToCart();
              Navigator.of(context).pop();
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text('Added $count offer items to cart'),
              //     backgroundColor: AppColors.success,
              //   ),
              // );
            },
          ),
        AppButton(
          label: 'Close',
          variant: AppButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
