import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/invoice_number_generator.dart';
import '../model/bill_model.dart';
import '../model/bill_item_model.dart';

abstract class IBillingRepository {
  Future<String> generateNextInvoiceNumber(DateTime date);
  Future<BillModel> createBill(BillModel bill, List<BillItemModel> items);
  Future<BillModel> updateBill(BillModel bill, List<BillItemModel> items);
  Future<BillModel?> getBillWithItems(int billId);
  Future<void> deleteBill(int billId);
}

class BillingRepository implements IBillingRepository {
  final Database db;

  BillingRepository({required this.db});

  @override
  Future<String> generateNextInvoiceNumber(DateTime date) async {
    final dateCompact = AppDateUtils.formatCompact(date);
    final prefix = 'INV-$dateCompact-';

    // Find all invoices with this date prefix to determine next sequence
    final results = await db.query(
      DatabaseConstants.tableBills,
      columns: [DatabaseConstants.colBillInvoiceNumber],
      where: '${DatabaseConstants.colBillInvoiceNumber} LIKE ?',
      whereArgs: ['$prefix%'],
      orderBy: '${DatabaseConstants.colBillInvoiceNumber} DESC',
      limit: 1,
    );

    int nextSeq = 1;
    if (results.isNotEmpty) {
      final lastInvoice = results.first[DatabaseConstants.colBillInvoiceNumber] as String;
      final parts = lastInvoice.split('-');
      if (parts.length == 3) {
        final lastSeq = int.tryParse(parts[2]);
        if (lastSeq != null) {
          nextSeq = lastSeq + 1;
        }
      }
    }

    return InvoiceNumberGenerator.generate(date, nextSeq);
  }

  @override
  Future<BillModel> createBill(BillModel bill, List<BillItemModel> items) async {
    return await db.transaction((txn) async {
      // 1. Insert bill header
      final billId = await txn.insert(
        DatabaseConstants.tableBills,
        bill.toMap(),
      );

      // 2. Insert snapshot bill items
      final savedItems = <BillItemModel>[];
      for (final item in items) {
        final itemId = await txn.insert(
          DatabaseConstants.tableBillItems,
          item.toMap(overrideBillId: billId),
        );
        savedItems.add(item.copyWith(id: itemId, billId: billId));
      }

      return bill.copyWith(id: billId, items: savedItems);
    });
  }

  @override
  Future<BillModel> updateBill(BillModel bill, List<BillItemModel> items) async {
    if (bill.id == null) {
      throw ArgumentError('Cannot update a bill without an ID');
    }

    return await db.transaction((txn) async {
      // 1. Update bill header
      await txn.update(
        DatabaseConstants.tableBills,
        bill.toMap(),
        where: '${DatabaseConstants.colBillId} = ?',
        whereArgs: [bill.id],
      );

      // 2. Delete existing items to avoid stale records
      await txn.delete(
        DatabaseConstants.tableBillItems,
        where: '${DatabaseConstants.colBillItemBillId} = ?',
        whereArgs: [bill.id],
      );

      // 3. Insert updated snapshot items
      final savedItems = <BillItemModel>[];
      for (final item in items) {
        final itemId = await txn.insert(
          DatabaseConstants.tableBillItems,
          item.toMap(overrideBillId: bill.id),
        );
        savedItems.add(item.copyWith(id: itemId, billId: bill.id));
      }

      return bill.copyWith(items: savedItems);
    });
  }

  @override
  Future<BillModel?> getBillWithItems(int billId) async {
    final billRows = await db.query(
      DatabaseConstants.tableBills,
      where: '${DatabaseConstants.colBillId} = ?',
      whereArgs: [billId],
      limit: 1,
    );

    if (billRows.isEmpty) return null;

    final itemRows = await db.query(
      DatabaseConstants.tableBillItems,
      where: '${DatabaseConstants.colBillItemBillId} = ?',
      whereArgs: [billId],
      orderBy: '${DatabaseConstants.colBillItemId} ASC',
    );

    final items = itemRows.map((row) => BillItemModel.fromMap(row)).toList();
    return BillModel.fromMap(billRows.first, items: items);
  }

  @override
  Future<void> deleteBill(int billId) async {
    await db.transaction((txn) async {
      await txn.delete(
        DatabaseConstants.tableBillItems,
        where: '${DatabaseConstants.colBillItemBillId} = ?',
        whereArgs: [billId],
      );
      await txn.delete(
        DatabaseConstants.tableBills,
        where: '${DatabaseConstants.colBillId} = ?',
        whereArgs: [billId],
      );
    });
  }
}
