import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_constants.dart';
import '../../billing/model/bill_model.dart';

abstract class IBillingHistoryRepository {
  Future<List<BillModel>> getBills({DateTime? startDate, DateTime? endDate});
}

class BillingHistoryRepository implements IBillingHistoryRepository {
  final Database db;

  BillingHistoryRepository({required this.db});

  @override
  Future<List<BillModel>> getBills({DateTime? startDate, DateTime? endDate}) async {
    String? whereClause;
    List<dynamic>? whereArgs;

    if (startDate != null && endDate != null) {
      whereClause = '${DatabaseConstants.colBillCreatedAt} >= ? AND ${DatabaseConstants.colBillCreatedAt} <= ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    } else if (startDate != null) {
      whereClause = '${DatabaseConstants.colBillCreatedAt} >= ?';
      whereArgs = [startDate.toIso8601String()];
    } else if (endDate != null) {
      whereClause = '${DatabaseConstants.colBillCreatedAt} <= ?';
      whereArgs = [endDate.toIso8601String()];
    }

    final rows = await db.query(
      DatabaseConstants.tableBills,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: '${DatabaseConstants.colBillCreatedAt} DESC',
    );

    return rows.map((row) => BillModel.fromMap(row)).toList();
  }
}
