import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../provider/product_provider.dart';
import 'add_product_dialog.dart';
import 'product_item.dart';

class ProductList extends ConsumerWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredProductsProvider);
    final searchQuery = ref.watch(productSearchQueryProvider);

    return filteredAsync.when(
      loading: () => const LoadingWidget(message: 'Loading products...'),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 12),
              Text('Failed to load products: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(productListProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          if (searchQuery.isNotEmpty) {
            return EmptyState(
              icon: Icons.search_off,
              title: 'No products found',
              subtitle: 'No products match "$searchQuery"',
              actionLabel: 'Add this Product',
              onAction: () => AddProductDialog.show(context),
            );
          }
          return EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No products available',
            subtitle: 'Start by adding your first product to create bills quickly.',
            actionLabel: '+ Add First Product',
            onAction: () => AddProductDialog.show(context),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: products.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductItem(key: ValueKey(product.id), product: product);
          },
        );
      },
    );
  }
}
