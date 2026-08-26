import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_constants.dart';
import '../model/product_model.dart';

abstract class IProductRepository {
  Future<List<ProductModel>> getAllProducts();
  Future<List<ProductModel>> searchProducts(String query);
  Future<ProductModel> createProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(int id);
}

class ProductRepository implements IProductRepository {
  final Database db;

  ProductRepository({required this.db});

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final rows = await db.query(
      DatabaseConstants.tableProducts,
      orderBy: '${DatabaseConstants.colProductName} ASC',
    );
    return rows.map((row) => ProductModel.fromMap(row)).toList();
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      return getAllProducts();
    }
    final rows = await db.query(
      DatabaseConstants.tableProducts,
      where: '${DatabaseConstants.colProductName} LIKE ?',
      whereArgs: ['%${query.trim()}%'],
      orderBy: '${DatabaseConstants.colProductName} ASC',
    );
    return rows.map((row) => ProductModel.fromMap(row)).toList();
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final id = await db.insert(
      DatabaseConstants.tableProducts,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return product.copyWith(id: id);
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    if (product.id == null) return;
    await db.update(
      DatabaseConstants.tableProducts,
      product.toMap(),
      where: '${DatabaseConstants.colProductId} = ?',
      whereArgs: [product.id],
    );
  }

  @override
  Future<void> deleteProduct(int id) async {
    await db.delete(
      DatabaseConstants.tableProducts,
      where: '${DatabaseConstants.colProductId} = ?',
      whereArgs: [id],
    );
  }
}
