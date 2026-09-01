import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/currency_utils.dart';
import '../model/product_model.dart';
import 'cart_provider.dart';

class OfferGroupState {
  final int group;
  final double totalPrice;
  final List<ProductModel> products;

  const OfferGroupState({
    required this.group,
    this.totalPrice = 0.0,
    this.products = const [],
  });

  OfferGroupState copyWith({
    int? group,
    double? totalPrice,
    List<ProductModel>? products,
  }) {
    return OfferGroupState(
      group: group ?? this.group,
      totalPrice: totalPrice != null
          ? CurrencyUtils.round(totalPrice)
          : this.totalPrice,
      products: products ?? this.products,
    );
  }
}

final offerListFamilyProvider =
    AsyncNotifierProviderFamily<OfferNotifier, OfferGroupState, int>(() {
      return OfferNotifier();
    });

/// Helper provider to get which offer groups (1, 2, 3, 4) contain a specific product
final offerGroupsForProductProvider =
    Provider.family<List<int>, String>((ref, productName) {
      final groups = <int>[];
      for (final group in [1, 2, 3, 4]) {
        final offerGroupState =
            ref.watch(offerListFamilyProvider(group)).valueOrNull;
        final list = offerGroupState?.products ?? [];
        if (list.any(
          (p) =>
              p.name.toLowerCase().trim() == productName.toLowerCase().trim(),
        )) {
          groups.add(group);
        }
      }
      return groups;
    });

class OfferNotifier extends FamilyAsyncNotifier<OfferGroupState, int> {
  @override
  Future<OfferGroupState> build(int arg) async {
    final repo = ref.watch(offerRepositoryProvider);
    final products = await repo.getOfferProducts(offerGroup: arg);
    final totalPrice = await repo.getOfferGroupTotalPrice(arg);
    return OfferGroupState(
      group: arg,
      totalPrice: totalPrice,
      products: products,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> setTotalPrice(double newTotalPrice) async {
    final repo = ref.read(offerRepositoryProvider);
    final rounded = CurrencyUtils.round(newTotalPrice.clamp(0.0, double.infinity));
    await repo.setOfferGroupTotalPrice(arg, rounded);
    final current = state.valueOrNull ?? OfferGroupState(group: arg);
    state = AsyncData(current.copyWith(totalPrice: rounded));
  }

  Future<bool> toggleOffer(ProductModel product) async {
    final repo = ref.read(offerRepositoryProvider);
    final current = state.valueOrNull ?? OfferGroupState(group: arg);
    final currentList = current.products;
    final exists = currentList.any(
      (p) => p.name.toLowerCase().trim() == product.name.toLowerCase().trim(),
    );

    if (exists) {
      await repo.removeOfferProduct(product.name, offerGroup: arg);
      final updatedList = currentList
          .where(
            (p) =>
                p.name.toLowerCase().trim() !=
                product.name.toLowerCase().trim(),
          )
          .toList();
      state = AsyncData(current.copyWith(products: updatedList));
      return false; // removed
    } else {
      await repo.addOfferProduct(product, offerGroup: arg);
      state = AsyncData(current.copyWith(products: [...currentList, product]));
      return true; // added
    }
  }

  Future<void> addOffer(ProductModel product) async {
    final repo = ref.read(offerRepositoryProvider);
    final current = state.valueOrNull ?? OfferGroupState(group: arg);
    final currentList = current.products;
    final exists = currentList.any(
      (p) => p.name.toLowerCase().trim() == product.name.toLowerCase().trim(),
    );
    if (!exists) {
      await repo.addOfferProduct(product, offerGroup: arg);
      state = AsyncData(current.copyWith(products: [...currentList, product]));
    }
  }

  Future<void> removeOffer(ProductModel product) async {
    final repo = ref.read(offerRepositoryProvider);
    final current = state.valueOrNull ?? OfferGroupState(group: arg);
    final currentList = current.products;
    await repo.removeOfferProduct(product.name, offerGroup: arg);
    final updatedList = currentList
        .where(
          (p) =>
              p.name.toLowerCase().trim() !=
              product.name.toLowerCase().trim(),
        )
        .toList();
    state = AsyncData(current.copyWith(products: updatedList));
  }

  bool isOffer(ProductModel product) {
    final current = state.valueOrNull ?? OfferGroupState(group: arg);
    return current.products.any(
      (p) => p.name.toLowerCase().trim() == product.name.toLowerCase().trim(),
    );
  }

  int addAllOffersToCart() {
    final current = state.valueOrNull;
    if (current == null || current.products.isEmpty) return 0;

    final cartNotifier = ref.read(cartProvider.notifier);
    cartNotifier.addOfferToCart(
      products: current.products,
      offerTotalPrice: current.totalPrice,
    );
    return current.products.length;
  }
}

