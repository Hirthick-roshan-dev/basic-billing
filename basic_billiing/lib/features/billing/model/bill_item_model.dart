import '../../../core/database/database_constants.dart';
import '../../../core/utils/currency_utils.dart';

class BillItemModel {
  final int? id;
  final int? billId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;

  BillItemModel({
    this.id,
    this.billId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap({int? overrideBillId}) {
    final map = <String, dynamic>{
      DatabaseConstants.colBillItemBillId: overrideBillId ?? billId,
      DatabaseConstants.colBillItemProductName: productName,
      DatabaseConstants.colBillItemUnitPrice: CurrencyUtils.round(unitPrice),
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
      unitPrice: CurrencyUtils.round((map[DatabaseConstants.colBillItemUnitPrice] as num).toDouble()),
      quantity: map[DatabaseConstants.colBillItemQuantity] as int,
      totalPrice: CurrencyUtils.round((map[DatabaseConstants.colBillItemTotalPrice] as num).toDouble()),
    );
  }

  BillItemModel copyWith({
    int? id,
    int? billId,
    String? productName,
    double? unitPrice,
    int? quantity,
    double? totalPrice,
  }) {
    return BillItemModel(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice != null ? CurrencyUtils.round(unitPrice) : this.unitPrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice != null ? CurrencyUtils.round(totalPrice) : this.totalPrice,
    );
  }
}
