import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../model/product_model.dart';
import 'cart_provider.dart';

final offerListProvider =
    AsyncNotifierProvider<OfferNotifier, List<ProductModel>>(() {
  return OfferNotifier();
});

class OfferNotifier extends AsyncNotifier<List<ProductModel>> {
  @override
  Future<List<ProductModel>> build() async {
    final repo = ref.watch(offerRepositoryProvider);
    return await repo.getOfferProducts();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<bool> toggleOffer(ProductModel product) async {
    final repo = ref.read(offerRepositoryProvider);
    final currentList = state.valueOrNull ?? [];
    final exists = currentList.any(
      (p) => p.name.toLowerCase().trim() == product.name.toLowerCase().trim(),
    );

    if (exists) {
      await repo.removeOfferProduct(product.name);
      state = AsyncData(
        currentList
            .where((p) =>
                p.name.toLowerCase().trim() !=
                product.name.toLowerCase().trim())
            .toList(),
      );
      return false; // removed
    } else {
      await repo.addOfferProduct(product);
      state = AsyncData([...currentList, product]);
      return true; // added
    }
  }

  Future<void> addOffer(ProductModel product) async {
    final repo = ref.read(offerRepositoryProvider);
    final currentList = state.valueOrNull ?? [];
    final exists = currentList.any(
      (p) => p.name.toLowerCase().trim() == product.name.toLowerCase().trim(),
    );
    if (!exists) {
      await repo.addOfferProduct(product);
      state = AsyncData([...currentList, product]);
    }
  }

  Future<void> removeOffer(ProductModel product) async {
    final repo = ref.read(offerRepositoryProvider);
    final currentList = state.valueOrNull ?? [];
    await repo.removeOfferProduct(product.name);
    state = AsyncData(
      currentList
          .where((p) =>
              p.name.toLowerCase().trim() !=
              product.name.toLowerCase().trim())
          .toList(),
    );
  }

  bool isOffer(ProductModel product) {
    final currentList = state.valueOrNull ?? [];
    return currentList.any(
      (p) => p.name.toLowerCase().trim() == product.name.toLowerCase().trim(),
    );
  }

  int addAllOffersToCart() {
    final currentList = state.valueOrNull ?? [];
    if (currentList.isEmpty) return 0;

    final cartNotifier = ref.read(cartProvider.notifier);
    for (final product in currentList) {
      cartNotifier.addProduct(product);
    }
    return currentList.length;
  }
}
