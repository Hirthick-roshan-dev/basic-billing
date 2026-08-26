import '../../../core/database/database_constants.dart';
import '../../../core/utils/currency_utils.dart';
import 'bill_item_model.dart';

class BillModel {
  final int? id;
  final String invoiceNumber;
  final String? customerName;
  final String? customerPhone;
  final double subtotal;
  final double discountPercent;
  final double discountAmount;
  final double taxPercent;
  final double taxAmount;
  final double totalAmount;
  final bool isTotalEdited;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<BillItemModel> items;

  BillModel({
    this.id,
    required this.invoiceNumber,
    this.customerName,
    this.customerPhone,
    required this.subtotal,
    this.discountPercent = 0.0,
    this.discountAmount = 0.0,
    this.taxPercent = 0.0,
    this.taxAmount = 0.0,
    required this.totalAmount,
    this.isTotalEdited = false,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      DatabaseConstants.colBillInvoiceNumber: invoiceNumber,
      DatabaseConstants.colBillCustomerName: customerName,
      DatabaseConstants.colBillCustomerPhone: customerPhone,
      DatabaseConstants.colBillSubtotal: CurrencyUtils.round(subtotal),
      DatabaseConstants.colBillDiscountPercent: CurrencyUtils.round(discountPercent),
      DatabaseConstants.colBillDiscountAmount: CurrencyUtils.round(discountAmount),
      DatabaseConstants.colBillTaxPercent: CurrencyUtils.round(taxPercent),
      DatabaseConstants.colBillTaxAmount: CurrencyUtils.round(taxAmount),
      DatabaseConstants.colBillTotalAmount: CurrencyUtils.round(totalAmount),
      DatabaseConstants.colBillIsTotalEdited: isTotalEdited ? 1 : 0,
      DatabaseConstants.colBillCreatedAt: createdAt.toIso8601String(),
      DatabaseConstants.colBillUpdatedAt: updatedAt?.toIso8601String(),
    };
    if (id != null) {
      map[DatabaseConstants.colBillId] = id;
    }
    return map;
  }

  factory BillModel.fromMap(Map<String, dynamic> map, {List<BillItemModel> items = const []}) {
    return BillModel(
      id: map[DatabaseConstants.colBillId] as int?,
      invoiceNumber: map[DatabaseConstants.colBillInvoiceNumber] as String,
      customerName: map[DatabaseConstants.colBillCustomerName] as String?,
      customerPhone: map[DatabaseConstants.colBillCustomerPhone] as String?,
      subtotal: CurrencyUtils.round((map[DatabaseConstants.colBillSubtotal] as num).toDouble()),
      discountPercent: CurrencyUtils.round((map[DatabaseConstants.colBillDiscountPercent] as num?)?.toDouble() ?? 0.0),
      discountAmount: CurrencyUtils.round((map[DatabaseConstants.colBillDiscountAmount] as num?)?.toDouble() ?? 0.0),
      taxPercent: CurrencyUtils.round((map[DatabaseConstants.colBillTaxPercent] as num?)?.toDouble() ?? 0.0),
      taxAmount: CurrencyUtils.round((map[DatabaseConstants.colBillTaxAmount] as num?)?.toDouble() ?? 0.0),
      totalAmount: CurrencyUtils.round((map[DatabaseConstants.colBillTotalAmount] as num).toDouble()),
      isTotalEdited: (map[DatabaseConstants.colBillIsTotalEdited] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map[DatabaseConstants.colBillCreatedAt] as String),
      updatedAt: map[DatabaseConstants.colBillUpdatedAt] != null
          ? DateTime.parse(map[DatabaseConstants.colBillUpdatedAt] as String)
          : null,
      items: items,
    );
  }

  BillModel copyWith({
    int? id,
    String? invoiceNumber,
    String? customerName,
    String? customerPhone,
    double? subtotal,
    double? discountPercent,
    double? discountAmount,
    double? taxPercent,
    double? taxAmount,
    double? totalAmount,
    bool? isTotalEdited,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<BillItemModel>? items,
  }) {
    return BillModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      subtotal: subtotal != null ? CurrencyUtils.round(subtotal) : this.subtotal,
      discountPercent: discountPercent != null ? CurrencyUtils.round(discountPercent) : this.discountPercent,
      discountAmount: discountAmount != null ? CurrencyUtils.round(discountAmount) : this.discountAmount,
      taxPercent: taxPercent != null ? CurrencyUtils.round(taxPercent) : this.taxPercent,
      taxAmount: taxAmount != null ? CurrencyUtils.round(taxAmount) : this.taxAmount,
      totalAmount: totalAmount != null ? CurrencyUtils.round(totalAmount) : this.totalAmount,
      isTotalEdited: isTotalEdited ?? this.isTotalEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}
