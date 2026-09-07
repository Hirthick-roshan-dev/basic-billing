import '../../../core/database/database_constants.dart';
import '../../../core/utils/currency_utils.dart';

class BillItemModel {
  final int? id;
  final int? billId;
  final String productName;
  final double unitPrice;
  final double purchasePrice;
  final int quantity;
  final double totalPrice;

  BillItemModel({
    this.id,
    this.billId,
    required this.productName,
    required this.unitPrice,
    this.purchasePrice = 0.0,
    required this.quantity,
    required this.totalPrice,
  });

  double get totalPurchasePrice => CurrencyUtils.round(purchasePrice * quantity);

  Map<String, dynamic> toMap({int? overrideBillId}) {
    final map = <String, dynamic>{
      DatabaseConstants.colBillItemBillId: overrideBillId ?? billId,
      DatabaseConstants.colBillItemProductName: productName,
      DatabaseConstants.colBillItemUnitPrice: CurrencyUtils.round(unitPrice),
      DatabaseConstants.colBillItemPurchasePrice: CurrencyUtils.round(purchasePrice),
      DatabaseConstants.colBillItemQuantity: quantity,
      DatabaseConstants.colBillItemTotalPrice: CurrencyUtils.round(totalPrice),
    };
    if (id != null) {
      map[DatabaseConstants.colBillItemId] = id;
    }
    return map;
  }

  factory BillItemModel.fromMap(Map<String, dynamic> map) {
    return BillItemModel(
      id: map[DatabaseConstants.colBillItemId] as int?,
      billId: map[DatabaseConstants.colBillItemBillId] as int?,
      productName: map[DatabaseConstants.colBillItemProductName] as String,
      unitPrice: CurrencyUtils.round(
        (map[DatabaseConstants.colBillItemUnitPrice] as num).toDouble(),
      ),
      purchasePrice: map[DatabaseConstants.colBillItemPurchasePrice] != null
          ? CurrencyUtils.round(
              (map[DatabaseConstants.colBillItemPurchasePrice] as num).toDouble(),
            )
          : 0.0,
      quantity: map[DatabaseConstants.colBillItemQuantity] as int,
      totalPrice: CurrencyUtils.round(
        (map[DatabaseConstants.colBillItemTotalPrice] as num).toDouble(),
      ),
    );
  }

  BillItemModel copyWith({
    int? id,
    int? billId,
    String? productName,
    double? unitPrice,
    double? purchasePrice,
    int? quantity,
    double? totalPrice,
  }) {
    return BillItemModel(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice != null
          ? CurrencyUtils.round(unitPrice)
          : this.unitPrice,
      purchasePrice: purchasePrice != null
          ? CurrencyUtils.round(purchasePrice)
          : this.purchasePrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice != null
          ? CurrencyUtils.round(totalPrice)
          : this.totalPrice,
    );
  }
}
