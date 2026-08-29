import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_constants.dart';
import '../model/product_model.dart';

abstract class IOfferRepository {
  Future<List<ProductModel>> getOfferProducts();
  Future<void> addOfferProduct(ProductModel product);
  Future<void> removeOfferProduct(String productName);
  Future<bool> isOfferProduct(String productName);
  Future<void> clearOfferProducts();
}

class OfferRepository implements IOfferRepository {
  final Database db;

  OfferRepository({required this.db});

  Future<void> _ensureTable() async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableOfferProducts} (
        ${DatabaseConstants.colOfferId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colOfferProductId} INTEGER,
        ${DatabaseConstants.colOfferProductName} TEXT NOT NULL UNIQUE,
        ${DatabaseConstants.colOfferProductPrice} REAL NOT NULL,
        ${DatabaseConstants.colOfferCreatedAt} TEXT NOT NULL
      )
    ''');
  }

  @override
  Future<List<ProductModel>> getOfferProducts() async {
    await _ensureTable();
    final rows = await db.query(
      DatabaseConstants.tableOfferProducts,
      orderBy: '${DatabaseConstants.colOfferProductName} ASC',
    );

    return rows.map((row) {
      return ProductModel(
        id: row[DatabaseConstants.colOfferProductId] as int?,
        name: row[DatabaseConstants.colOfferProductName] as String,
        price: (row[DatabaseConstants.colOfferProductPrice] as num).toDouble(),
        createdAt: DateTime.tryParse(row[DatabaseConstants.colOfferCreatedAt] as String? ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> addOfferProduct(ProductModel product) async {
    await _ensureTable();
    await db.insert(
      DatabaseConstants.tableOfferProducts,
      {
        DatabaseConstants.colOfferProductId: product.id,
        DatabaseConstants.colOfferProductName: product.name,
        DatabaseConstants.colOfferProductPrice: product.price,
        DatabaseConstants.colOfferCreatedAt: DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeOfferProduct(String productName) async {
    await _ensureTable();
    await db.delete(
      DatabaseConstants.tableOfferProducts,
      where: 'LOWER(${DatabaseConstants.colOfferProductName}) = ?',
      whereArgs: [productName.toLowerCase().trim()],
    );
  }

  @override
  Future<bool> isOfferProduct(String productName) async {
    await _ensureTable();
    final rows = await db.query(
      DatabaseConstants.tableOfferProducts,
      where: 'LOWER(${DatabaseConstants.colOfferProductName}) = ?',
      whereArgs: [productName.toLowerCase().trim()],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  @override
  Future<void> clearOfferProducts() async {
    await _ensureTable();
    await db.delete(DatabaseConstants.tableOfferProducts);
  }
}
