import '../../../core/database/database_constants.dart';
import '../../../core/utils/currency_utils.dart';
import 'bill_item_model.dart';

class BillModel {
  final int? id;
  final String invoiceNumber;
  final String? customerName;
  final String? customerPhone;
  final String? vehicleNumber;
  final String? vehicleModel;
  final String? km;
  final String? jobCardNumber;
  final String paymentType;
  final String? purchaseShopName;
  final String? purchasePaymentType;
  final double subtotal;
  final double discountPercent;
  final double discountAmount;
  final double taxPercent;
  final double taxAmount;
  final double totalAmount;
  final double totalPurchaseAmount;
  final bool isTotalEdited;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<BillItemModel> items;

  BillModel({
    this.id,
    required this.invoiceNumber,
    this.customerName,
    this.customerPhone,
    this.vehicleNumber,
    this.vehicleModel,
    this.km,
    this.jobCardNumber,
    this.paymentType = 'Cash',
    this.purchaseShopName,
    this.purchasePaymentType = 'Cash',
    required this.subtotal,
    this.discountPercent = 0.0,
    this.discountAmount = 0.0,
    this.taxPercent = 0.0,
    this.taxAmount = 0.0,
    required this.totalAmount,
    this.totalPurchaseAmount = 0.0,
    this.isTotalEdited = false,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  double get profitOrLoss => CurrencyUtils.round(totalAmount - totalPurchaseAmount);

  bool get isProfit => profitOrLoss >= 0;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      DatabaseConstants.colBillInvoiceNumber: invoiceNumber,
      DatabaseConstants.colBillCustomerName: customerName,
      DatabaseConstants.colBillCustomerPhone: customerPhone,
      DatabaseConstants.colBillVehicleNumber: vehicleNumber,
      DatabaseConstants.colBillVehicleModel: vehicleModel,
      DatabaseConstants.colBillKm: km,
      DatabaseConstants.colBillJobCardNumber: jobCardNumber,
      DatabaseConstants.colBillPaymentType: paymentType,
      DatabaseConstants.colBillPurchaseShopName: purchaseShopName,
      DatabaseConstants.colBillPurchasePaymentType: purchasePaymentType,
      DatabaseConstants.colBillSubtotal: CurrencyUtils.round(subtotal),
      DatabaseConstants.colBillDiscountPercent: CurrencyUtils.round(
        discountPercent,
      ),
      DatabaseConstants.colBillDiscountAmount: CurrencyUtils.round(
        discountAmount,
      ),
      DatabaseConstants.colBillTaxPercent: CurrencyUtils.round(taxPercent),
      DatabaseConstants.colBillTaxAmount: CurrencyUtils.round(taxAmount),
      DatabaseConstants.colBillTotalAmount: CurrencyUtils.round(totalAmount),
      DatabaseConstants.colBillTotalPurchaseAmount: CurrencyUtils.round(totalPurchaseAmount),
      DatabaseConstants.colBillIsTotalEdited: isTotalEdited ? 1 : 0,
      DatabaseConstants.colBillCreatedAt: createdAt.toIso8601String(),
      DatabaseConstants.colBillUpdatedAt: updatedAt?.toIso8601String(),
    };
    if (id != null) {
      map[DatabaseConstants.colBillId] = id;
    }
    return map;
  }

  factory BillModel.fromMap(
    Map<String, dynamic> map, {
    List<BillItemModel> items = const [],
  }) {
    return BillModel(
      id: map[DatabaseConstants.colBillId] as int?,
      invoiceNumber: map[DatabaseConstants.colBillInvoiceNumber] as String,
      customerName: map[DatabaseConstants.colBillCustomerName] as String?,
      customerPhone: map[DatabaseConstants.colBillCustomerPhone] as String?,
      vehicleNumber: map[DatabaseConstants.colBillVehicleNumber] as String?,
      vehicleModel: map[DatabaseConstants.colBillVehicleModel] as String?,
      km: map[DatabaseConstants.colBillKm] as String?,
      jobCardNumber: map[DatabaseConstants.colBillJobCardNumber] as String?,
      paymentType:
          (map[DatabaseConstants.colBillPaymentType] as String?) ?? 'Cash',
      purchaseShopName:
          map[DatabaseConstants.colBillPurchaseShopName] as String?,
      purchasePaymentType:
          (map[DatabaseConstants.colBillPurchasePaymentType] as String?) ??
              'Cash',
      subtotal: CurrencyUtils.round(
        (map[DatabaseConstants.colBillSubtotal] as num).toDouble(),
      ),
      discountPercent: CurrencyUtils.round(
        (map[DatabaseConstants.colBillDiscountPercent] as num?)?.toDouble() ??
            0.0,
      ),
      discountAmount: CurrencyUtils.round(
        (map[DatabaseConstants.colBillDiscountAmount] as num?)?.toDouble() ??
            0.0,
      ),
      taxPercent: CurrencyUtils.round(
        (map[DatabaseConstants.colBillTaxPercent] as num?)?.toDouble() ?? 0.0,
      ),
      taxAmount: CurrencyUtils.round(
        (map[DatabaseConstants.colBillTaxAmount] as num?)?.toDouble() ?? 0.0,
      ),
      totalAmount: CurrencyUtils.round(
        (map[DatabaseConstants.colBillTotalAmount] as num).toDouble(),
      ),
      totalPurchaseAmount: map[DatabaseConstants.colBillTotalPurchaseAmount] != null
          ? CurrencyUtils.round(
              (map[DatabaseConstants.colBillTotalPurchaseAmount] as num).toDouble(),
            )
          : 0.0,
      isTotalEdited:
          (map[DatabaseConstants.colBillIsTotalEdited] as int? ?? 0) == 1,
      createdAt: DateTime.parse(
        map[DatabaseConstants.colBillCreatedAt] as String,
      ),
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
    String? vehicleNumber,
    String? vehicleModel,
    String? km,
    String? jobCardNumber,
    String? paymentType,
    String? purchaseShopName,
    String? purchasePaymentType,
    double? subtotal,
    double? discountPercent,
    double? discountAmount,
    double? taxPercent,
    double? taxAmount,
    double? totalAmount,
    double? totalPurchaseAmount,
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
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      km: km ?? this.km,
      jobCardNumber: jobCardNumber ?? this.jobCardNumber,
      paymentType: paymentType ?? this.paymentType,
      purchaseShopName: purchaseShopName ?? this.purchaseShopName,
      purchasePaymentType: purchasePaymentType ?? this.purchasePaymentType,
      subtotal: subtotal != null
          ? CurrencyUtils.round(subtotal)
          : this.subtotal,
      discountPercent: discountPercent != null
          ? CurrencyUtils.round(discountPercent)
          : this.discountPercent,
      discountAmount: discountAmount != null
          ? CurrencyUtils.round(discountAmount)
          : this.discountAmount,
      taxPercent: taxPercent != null
          ? CurrencyUtils.round(taxPercent)
          : this.taxPercent,
      taxAmount: taxAmount != null
          ? CurrencyUtils.round(taxAmount)
          : this.taxAmount,
      totalAmount: totalAmount != null
          ? CurrencyUtils.round(totalAmount)
          : this.totalAmount,
      totalPurchaseAmount: totalPurchaseAmount != null
          ? CurrencyUtils.round(totalPurchaseAmount)
          : this.totalPurchaseAmount,
      isTotalEdited: isTotalEdited ?? this.isTotalEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}
