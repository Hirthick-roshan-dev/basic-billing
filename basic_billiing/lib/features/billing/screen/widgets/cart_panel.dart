import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../provider/cart_provider.dart';
import 'billing_summary.dart';
import 'cart_item.dart';
import 'complete_bill_button.dart';
import 'customer_section.dart';

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (Fixed at top)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cart (${cart.totalItemCount})',
                      style: AppTextStyles.sectionTitle,
                    ),
                  ],
                ),
                if (cart.isNotEmpty)
                  TextButton.icon(
                    icon: const Icon(
                      Icons.clear_all,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    label: const Text(
                      'Clear Cart',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () {
                      ref.read(cartProvider.notifier).clearCart();
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Body
          Expanded(
            child: cart.isEmpty
                ? const EmptyState(
                    icon: Icons.add_shopping_cart_rounded,
                    title: 'Cart is empty',
                    subtitle:
                        'Click products on the left panel to add them to this bill.',
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Cart Items
                      ...cart.items.map((item) {
                        return Padding(
                          key: ValueKey(item.productName),
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CartItemWidget(item: item),
                        );
                      }),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(),
                      ),

                      // Customer details section
                      const CustomerSection(),
                      const SizedBox(height: 14),

                      // Financial summary calculations
                      const BillingSummary(),
                      const SizedBox(height: 16),

                      // Complete bill action button
                      const CompleteBillButton(),
                      const SizedBox(height: 8),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
