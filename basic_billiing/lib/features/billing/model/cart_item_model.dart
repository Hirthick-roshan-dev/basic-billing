import '../../../core/utils/currency_utils.dart';

class CartItemModel {
  final int? productId;
  final String productName;
  final double unitPrice;
  final double purchasePrice;
  final int quantity;

  CartItemModel({
    this.productId,
    required this.productName,
    required this.unitPrice,
    this.purchasePrice = 0.0,
    this.quantity = 1,
  });

  double get totalPrice => CurrencyUtils.round(unitPrice * quantity);

  double get totalPurchasePrice => CurrencyUtils.round(purchasePrice * quantity);

  CartItemModel copyWith({
    int? productId,
    String? productName,
    double? unitPrice,
    double? purchasePrice,
    int? quantity,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice != null
          ? CurrencyUtils.round(unitPrice)
          : this.unitPrice,
      purchasePrice: purchasePrice != null
          ? CurrencyUtils.round(purchasePrice)
          : this.purchasePrice,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModel &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          productName == other.productName &&
          unitPrice == other.unitPrice &&
          purchasePrice == other.purchasePrice &&
          quantity == other.quantity;

  @override
  int get hashCode =>
      productId.hashCode ^
      productName.hashCode ^
      unitPrice.hashCode ^
      purchasePrice.hashCode ^
      quantity.hashCode;
}
