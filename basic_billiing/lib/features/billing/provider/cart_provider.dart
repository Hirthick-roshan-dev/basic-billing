import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_utils.dart';
import '../model/bill_model.dart';
import '../model/cart_item_model.dart';
import '../model/product_model.dart';
import '../../settings/provider/settings_provider.dart';

class CartState {
  final List<CartItemModel> items;
  final String customerName;
  final String customerPhone;
  final String vehicleNumber;
  final String vehicleModel;
  final String km;
  final String jobCardNumber;
  final double discountAmount;
  final bool taxEnabled;
  final double taxPercent;
  final bool isTotalEdited;
  final double? manualTotal;

  const CartState({
    this.items = const [],
    this.customerName = '',
    this.customerPhone = '',
    this.vehicleNumber = '',
    this.vehicleModel = '',
    this.km = '',
    this.jobCardNumber = '',
    this.discountAmount = 0.0,
    this.taxEnabled = false,
    this.taxPercent = 0.0,
    this.isTotalEdited = false,
    this.manualTotal,
  });

  // Centralized calculations
  double get subtotal {
    double sum = 0.0;
    for (final item in items) {
      sum += item.totalPrice;
    }
    return CurrencyUtils.round(sum);
  }

  /// Effective discount amount, clamped so it cannot exceed subtotal
  double get effectiveDiscountAmount {
    if (discountAmount <= 0 || subtotal <= 0) return 0.0;
    return CurrencyUtils.round(discountAmount.clamp(0.0, subtotal));
  }

  /// Computed discount percentage for reporting / backward-compatibility
  double get discountPercent {
    if (subtotal <= 0 || effectiveDiscountAmount <= 0) return 0.0;
    return CurrencyUtils.round((effectiveDiscountAmount / subtotal) * 100.0);
  }

  double get amountAfterDiscount {
    return CurrencyUtils.round(subtotal - effectiveDiscountAmount);
  }

  double get taxAmount {
    if (!taxEnabled || taxPercent <= 0 || amountAfterDiscount <= 0) return 0.0;
    return CurrencyUtils.round((amountAfterDiscount * taxPercent) / 100.0);
  }

  double get calculatedTotal {
    return CurrencyUtils.round(amountAfterDiscount + taxAmount);
  }

  double get payableTotal {
    if (isTotalEdited && manualTotal != null) {
      return CurrencyUtils.round(manualTotal!);
    }
    return calculatedTotal;
  }

  int get totalItemCount {
    int count = 0;
    for (final item in items) {
      count += item.quantity;
    }
    return count;
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  CartState copyWith({
    List<CartItemModel>? items,
    String? customerName,
    String? customerPhone,
    String? vehicleNumber,
    String? vehicleModel,
    String? km,
    String? jobCardNumber,
    double? discountAmount,
    bool? taxEnabled,
    double? taxPercent,
    bool? isTotalEdited,
    double? manualTotal,
    bool clearManualTotal = false,
  }) {
    return CartState(
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      km: km ?? this.km,
      jobCardNumber: jobCardNumber ?? this.jobCardNumber,
      discountAmount: discountAmount != null ? CurrencyUtils.round(discountAmount) : this.discountAmount,
      taxEnabled: taxEnabled ?? this.taxEnabled,
      taxPercent: taxPercent != null ? CurrencyUtils.round(taxPercent) : this.taxPercent,
      isTotalEdited: clearManualTotal ? false : (isTotalEdited ?? this.isTotalEdited),
      manualTotal: clearManualTotal ? null : (manualTotal ?? this.manualTotal),
    );
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    // Automatically initialize tax settings from SettingsProvider if available
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.valueOrNull;

    return CartState(
      taxEnabled: settings?.taxEnabled ?? false,
      taxPercent: settings?.taxPercent ?? 0.0,
    );
  }

  void addProduct(ProductModel product) {
    final existingIndex = state.items.indexWhere(
      (item) => item.productName.toLowerCase() == product.name.toLowerCase(),
    );

    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final updatedList = List<CartItemModel>.from(state.items);
      updatedList[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
      state = state.copyWith(items: updatedList);
    } else {
      final newItem = CartItemModel(
        productId: product.id,
        productName: product.name,
        unitPrice: product.price,
        quantity: 1,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void increaseQuantity(String productName) {
    final index = state.items.indexWhere((item) => item.productName == productName);
    if (index >= 0) {
      final updatedList = List<CartItemModel>.from(state.items);
      updatedList[index] = updatedList[index].copyWith(
        quantity: updatedList[index].quantity + 1,
      );
      state = state.copyWith(items: updatedList);
    }
  }

  void decreaseQuantity(String productName) {
    final index = state.items.indexWhere((item) => item.productName == productName);
    if (index >= 0) {
      final current = state.items[index];
      if (current.quantity > 1) {
        final updatedList = List<CartItemModel>.from(state.items);
        updatedList[index] = current.copyWith(quantity: current.quantity - 1);
        state = state.copyWith(items: updatedList);
      } else {
        removeItem(productName);
      }
    }
  }

  void removeItem(String productName) {
    state = state.copyWith(
      items: state.items.where((item) => item.productName != productName).toList(),
    );
  }

  void updateItemPrice(String productName, double newUnitPrice) {
    final index = state.items.indexWhere((item) => item.productName == productName);
    if (index >= 0) {
      final updatedList = List<CartItemModel>.from(state.items);
      updatedList[index] = updatedList[index].copyWith(
        unitPrice: CurrencyUtils.round(newUnitPrice.clamp(0.0, double.infinity)),
      );
      state = state.copyWith(items: updatedList);
    }
  }

  void setCustomerName(String name) {
    state = state.copyWith(customerName: name);
  }

  void setCustomerPhone(String phone) {
    state = state.copyWith(customerPhone: phone);
  }

  void setVehicleNumber(String vehicleNumber) {
    state = state.copyWith(vehicleNumber: vehicleNumber);
  }

  void setVehicleModel(String vehicleModel) {
    state = state.copyWith(vehicleModel: vehicleModel);
  }

  void setKm(String km) {
    state = state.copyWith(km: km);
  }

  void setJobCardNumber(String jobCardNumber) {
    state = state.copyWith(jobCardNumber: jobCardNumber);
  }

  void setDiscountAmount(double amount) {
    state = state.copyWith(discountAmount: CurrencyUtils.round(amount.clamp(0.0, double.infinity)));
  }

  void setDiscountPercent(double percent) {
    final calculatedAmount = (state.subtotal * percent) / 100.0;
    state = state.copyWith(discountAmount: CurrencyUtils.round(calculatedAmount));
  }

  void setTaxSettings({required bool enabled, required double percent}) {
    state = state.copyWith(
      taxEnabled: enabled,
      taxPercent: enabled ? CurrencyUtils.round(percent.clamp(0.0, 100.0)) : 0.0,
    );
  }

  void setManualTotal(double? total) {
    if (total == null) {
      state = state.copyWith(clearManualTotal: true);
    } else {
      state = state.copyWith(
        isTotalEdited: true,
        manualTotal: CurrencyUtils.round(total),
      );
    }
  }

  void resetManualTotal() {
    state = state.copyWith(clearManualTotal: true);
  }

  void loadFromBill(BillModel bill) {
    final cartItems = bill.items.map((i) {
      return CartItemModel(
        productName: i.productName,
        unitPrice: i.unitPrice,
        quantity: i.quantity,
      );
    }).toList();

    state = CartState(
      items: cartItems,
      customerName: bill.customerName ?? '',
      customerPhone: bill.customerPhone ?? '',
      vehicleNumber: bill.vehicleNumber ?? '',
      vehicleModel: bill.vehicleModel ?? '',
      km: bill.km ?? '',
      jobCardNumber: bill.jobCardNumber ?? '',
      discountAmount: bill.discountAmount,
      taxEnabled: bill.taxPercent > 0 || bill.taxAmount > 0,
      taxPercent: bill.taxPercent,
      isTotalEdited: bill.isTotalEdited,
      manualTotal: bill.isTotalEdited ? bill.totalAmount : null,
    );
  }

  void clearCart() {
    final settingsAsync = ref.read(settingsProvider);
    final settings = settingsAsync.valueOrNull;

    state = CartState(
      taxEnabled: settings?.taxEnabled ?? false,
      taxPercent: settings?.taxPercent ?? 0.0,
    );
  }
}
