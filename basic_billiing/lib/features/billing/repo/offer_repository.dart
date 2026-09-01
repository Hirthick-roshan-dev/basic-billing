import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_constants.dart';
import '../model/product_model.dart';

abstract class IOfferRepository {
  Future<List<ProductModel>> getOfferProducts({int offerGroup = 1});
  Future<void> addOfferProduct(ProductModel product, {int offerGroup = 1});
  Future<void> removeOfferProduct(String productName, {int offerGroup = 1});
  Future<bool> isOfferProduct(String productName, {int offerGroup = 1});
  Future<List<int>> getOfferGroupsForProduct(String productName);
  Future<void> clearOfferProducts({int? offerGroup});
  Future<double> getOfferGroupTotalPrice(int offerGroup);
  Future<void> setOfferGroupTotalPrice(int offerGroup, double totalPrice);
}

class OfferRepository implements IOfferRepository {
  final Database db;

  OfferRepository({required this.db});

  Future<void> _ensureTable() async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableOfferProducts} (
        ${DatabaseConstants.colOfferId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colOfferGroup} INTEGER NOT NULL DEFAULT 1,
        ${DatabaseConstants.colOfferProductId} INTEGER,
        ${DatabaseConstants.colOfferProductName} TEXT NOT NULL,
        ${DatabaseConstants.colOfferProductPrice} REAL NOT NULL,
        ${DatabaseConstants.colOfferCreatedAt} TEXT NOT NULL,
        UNIQUE(${DatabaseConstants.colOfferGroup}, ${DatabaseConstants.colOfferProductName})
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableOfferGroups} (
        ${DatabaseConstants.colOfferGroupId} INTEGER PRIMARY KEY,
        ${DatabaseConstants.colOfferGroupName} TEXT NOT NULL,
        ${DatabaseConstants.colOfferGroupTotalPrice} REAL NOT NULL DEFAULT 0.0,
        ${DatabaseConstants.colOfferGroupUpdatedAt} TEXT
      )
    ''');
  }

  @override
  Future<List<ProductModel>> getOfferProducts({int offerGroup = 1}) async {
    await _ensureTable();
    final rows = await db.query(
      DatabaseConstants.tableOfferProducts,
      where: '${DatabaseConstants.colOfferGroup} = ?',
      whereArgs: [offerGroup],
      orderBy: '${DatabaseConstants.colOfferId} ASC',
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
  Future<void> addOfferProduct(ProductModel product, {int offerGroup = 1}) async {
    await _ensureTable();
    await db.insert(
      DatabaseConstants.tableOfferProducts,
      {
        DatabaseConstants.colOfferGroup: offerGroup,
        DatabaseConstants.colOfferProductId: product.id,
        DatabaseConstants.colOfferProductName: product.name,
        DatabaseConstants.colOfferProductPrice: product.price,
        DatabaseConstants.colOfferCreatedAt: DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeOfferProduct(String productName, {int offerGroup = 1}) async {
    await _ensureTable();
    await db.delete(
      DatabaseConstants.tableOfferProducts,
      where: '${DatabaseConstants.colOfferGroup} = ? AND LOWER(${DatabaseConstants.colOfferProductName}) = ?',
      whereArgs: [offerGroup, productName.toLowerCase().trim()],
    );
  }

  @override
  Future<bool> isOfferProduct(String productName, {int offerGroup = 1}) async {
    await _ensureTable();
    final rows = await db.query(
      DatabaseConstants.tableOfferProducts,
      where: '${DatabaseConstants.colOfferGroup} = ? AND LOWER(${DatabaseConstants.colOfferProductName}) = ?',
      whereArgs: [offerGroup, productName.toLowerCase().trim()],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  @override
  Future<List<int>> getOfferGroupsForProduct(String productName) async {
    await _ensureTable();
    final rows = await db.query(
      DatabaseConstants.tableOfferProducts,
      columns: [DatabaseConstants.colOfferGroup],
      where: 'LOWER(${DatabaseConstants.colOfferProductName}) = ?',
      whereArgs: [productName.toLowerCase().trim()],
    );
    return rows.map((r) => (r[DatabaseConstants.colOfferGroup] as int?) ?? 1).toList();
  }

  @override
  Future<void> clearOfferProducts({int? offerGroup}) async {
    await _ensureTable();
    if (offerGroup != null) {
      await db.delete(
        DatabaseConstants.tableOfferProducts,
        where: '${DatabaseConstants.colOfferGroup} = ?',
        whereArgs: [offerGroup],
      );
    } else {
      await db.delete(DatabaseConstants.tableOfferProducts);
    }
  }

  @override
  Future<double> getOfferGroupTotalPrice(int offerGroup) async {
    await _ensureTable();
    final rows = await db.query(
      DatabaseConstants.tableOfferGroups,
      columns: [DatabaseConstants.colOfferGroupTotalPrice],
      where: '${DatabaseConstants.colOfferGroupId} = ?',
      whereArgs: [offerGroup],
      limit: 1,
    );

    if (rows.isNotEmpty) {
      return (rows.first[DatabaseConstants.colOfferGroupTotalPrice] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  @override
  Future<void> setOfferGroupTotalPrice(int offerGroup, double totalPrice) async {
    await _ensureTable();
    await db.insert(
      DatabaseConstants.tableOfferGroups,
      {
        DatabaseConstants.colOfferGroupId: offerGroup,
        DatabaseConstants.colOfferGroupName: 'Offer $offerGroup',
        DatabaseConstants.colOfferGroupTotalPrice: totalPrice,
        DatabaseConstants.colOfferGroupUpdatedAt: DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
