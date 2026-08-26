import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../model/product_model.dart';

final productListProvider = AsyncNotifierProvider<ProductListNotifier, List<ProductModel>>(() {
  return ProductListNotifier();
});

class ProductListNotifier extends AsyncNotifier<List<ProductModel>> {
  @override
  Future<List<ProductModel>> build() async {
    final repo = ref.watch(productRepositoryProvider);
    return await repo.getAllProducts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(productRepositoryProvider);
      return await repo.getAllProducts();
    });
  }

  Future<ProductModel> addProduct({required String name, required double price}) async {
    final newProduct = ProductModel(
      name: name.trim(),
      price: price,
      createdAt: DateTime.now(),
    );
    final repo = ref.read(productRepositoryProvider);
    final created = await repo.createProduct(newProduct);
    await refresh();
    return created;
  }

  Future<void> updateProduct(ProductModel product) async {
    final repo = ref.read(productRepositoryProvider);
    await repo.updateProduct(product.copyWith(updatedAt: DateTime.now()));
    await refresh();
  }

  Future<void> deleteProduct(int id) async {
    final repo = ref.read(productRepositoryProvider);
    await repo.deleteProduct(id);
    await refresh();
  }
}

final productSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider = Provider<AsyncValue<List<ProductModel>>>((ref) {
  final productsAsync = ref.watch(productListProvider);
  final query = ref.watch(productSearchQueryProvider).trim().toLowerCase();

  return productsAsync.whenData((products) {
    if (query.isEmpty) {
      return products;
    }
    return products
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  });
});
