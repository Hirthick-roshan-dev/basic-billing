import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../provider/billing_provider.dart';
import '../provider/billing_state.dart';
import '../provider/cart_provider.dart';
import 'widgets/bill_success_dialog.dart';
import 'widgets/cart_panel.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              mode.isEdit ? 'Edit Invoice ${mode.invoiceNumber}' : 'Create Bill',
              style: AppTextStyles.pageTitle,
            ),
            if (mode.isEdit) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              padding: const EdgeInsets.only(right: 16),
              child: TextButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Exit Edit Mode'),
                onPressed: () {
                  ref.read(billingProcessProvider.notifier).cancelEdit();
                },
              ),
            ),
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
                      children: const [
                        ProductSearchBar(),
                        SizedBox(height: 16),
                        Expanded(child: ProductList()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Right: Cart & Billing Panel
                  const Expanded(
                    flex: 5,
                    child: CartPanel(),
                  ),
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
                      const Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Products'),
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
                            children: const [
                              ProductSearchBar(),
                              SizedBox(height: 12),
                              Expanded(child: ProductList()),
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
}
