import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../provider/billing_provider.dart';
import '../provider/billing_state.dart';
import '../provider/cart_provider.dart';
import '../provider/offer_provider.dart';
import 'widgets/bill_success_dialog.dart';
import 'widgets/cart_panel.dart';
import 'widgets/offer_list_dialog.dart';
import 'widgets/product_list.dart';
import 'widgets/product_search_bar.dart';

class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(billingModeProvider);
    final cart = ref.watch(cartProvider);

    ref.listen<BillingProcessState>(billingProcessProvider, (prev, next) {
      if (next is BillingSuccessState) {
        BillSuccessDialog.show(context, next.bill, next.isEdit);
      } else if (next is BillingErrorState) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(next.message),
        //     backgroundColor: AppColors.error,
        //   ),
        // );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              mode.isEdit
                  ? 'Edit Invoice ${mode.invoiceNumber}'
                  : 'Create Bill',
              style: AppTextStyles.pageTitle,
            ),
            if (mode.isEdit) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.warning),
                ),
                child: const Text(
                  'EDIT MODE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (mode.isEdit)
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 8),
              child: TextButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Exit Edit Mode'),
                onPressed: () {
                  ref.read(billingProcessProvider.notifier).cancelEdit();
                },
              ),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 768;

          if (isWide) {
            // Two-panel layout
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left: Products Catalog
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ProductSearchBar(),
                        const SizedBox(height: 16),
                        _buildOfferActionsRow(context, ref),
                        const SizedBox(height: 16),
                        const Expanded(child: ProductList()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Right: Cart & Billing Panel
                  const Expanded(flex: 5, child: CartPanel()),
                ],
              ),
            );
          } else {
            // Smaller screens: Default to Products tab / Cart tab or vertical layout
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      const Tab(
                        icon: Icon(Icons.inventory_2_outlined),
                        text: 'Products',
                      ),
                      Tab(
                        icon: Badge(
                          label: Text('${cart.totalItemCount}'),
                          isLabelVisible: cart.isNotEmpty,
                          child: const Icon(Icons.shopping_cart_outlined),
                        ),
                        text: 'Cart (${cart.totalItemCount})',
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const ProductSearchBar(),
                              const SizedBox(height: 12),
                              _buildOfferActionsRow(context, ref),
                              const SizedBox(height: 12),
                              const Expanded(child: ProductList()),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: CartPanel(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildOfferActionsRow(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.local_offer_outlined, size: 18),
          label: const Text('Add Offer'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            final offers = ref.read(offerListProvider).valueOrNull ?? [];
            if (offers.isEmpty) {
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(
              //     content: Text(
              //       'No offer products found. Click the offer tag icon on products to add.',
              //     ),
              //   ),
              // );
            } else {
              final count = ref
                  .read(offerListProvider.notifier)
                  .addAllOffersToCart();
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text('Added $count offer items to cart'),
              //     backgroundColor: AppColors.success,
              //   ),
              // );
            }
          },
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.visibility_outlined),
          tooltip: 'View Offers',
          onPressed: () {
            OfferListDialog.show(context);
          },
        ),
      ],
    );
  }
}
