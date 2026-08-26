import '../../../core/database/database_constants.dart';
import '../../../core/utils/currency_utils.dart';

class ProductModel {
  final int? id;
  final String name;
  final double price;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.createdAt,
    this.updatedAt,
  });

  ProductModel copyWith({
    int? id,
    String? name,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price != null ? CurrencyUtils.round(price) : this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      DatabaseConstants.colProductName: name,
      DatabaseConstants.colProductPrice: CurrencyUtils.round(price),
      DatabaseConstants.colProductCreatedAt: createdAt.toIso8601String(),
      DatabaseConstants.colProductUpdatedAt: updatedAt?.toIso8601String(),
    };
    if (id != null) {
      map[DatabaseConstants.colProductId] = id;
    }
    return map;
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map[DatabaseConstants.colProductId] as int?,
      name: map[DatabaseConstants.colProductName] as String,
      price: CurrencyUtils.round((map[DatabaseConstants.colProductPrice] as num).toDouble()),
      createdAt: DateTime.parse(map[DatabaseConstants.colProductCreatedAt] as String),
      updatedAt: map[DatabaseConstants.colProductUpdatedAt] != null
          ? DateTime.parse(map[DatabaseConstants.colProductUpdatedAt] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          price == other.price;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ price.hashCode;
}
