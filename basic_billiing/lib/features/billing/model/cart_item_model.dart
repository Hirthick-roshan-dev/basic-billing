import '../../../core/utils/currency_utils.dart';

class CartItemModel {
  final int? productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  CartItemModel({
    this.productId,
    required this.productName,
    required this.unitPrice,
    this.quantity = 1,
  });

  double get totalPrice => CurrencyUtils.round(unitPrice * quantity);

  CartItemModel copyWith({
    int? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice != null ? CurrencyUtils.round(unitPrice) : this.unitPrice,
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
          quantity == other.quantity;

  @override
  int get hashCode =>
      productId.hashCode ^ productName.hashCode ^ unitPrice.hashCode ^ quantity.hashCode;
}
