import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:basic_billiing/core/database/database_migrations.dart';
import 'package:basic_billiing/features/billing/model/bill_model.dart';
import 'package:basic_billiing/features/billing/model/bill_item_model.dart';
import 'package:basic_billiing/features/billing/model/product_model.dart';
import 'package:basic_billiing/features/billing/repo/billing_repository.dart';
import 'package:basic_billiing/features/billing/repo/product_repository.dart';
import 'package:basic_billiing/features/billing_history/repo/billing_history_repository.dart';
import 'package:basic_billiing/features/settings/model/business_settings_model.dart';
import 'package:basic_billiing/features/settings/repo/settings_repository.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late ProductRepository productRepo;
  late BillingRepository billingRepo;
  late BillingHistoryRepository historyRepo;
  late SettingsRepository settingsRepo;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: DatabaseMigrations.onCreate,
      ),
    );

    productRepo = ProductRepository(db: db);
    billingRepo = BillingRepository(db: db);
    historyRepo = BillingHistoryRepository(db: db);
    settingsRepo = SettingsRepository(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Database & Repositories Integration Tests', () {
    test('Products CRUD operations work properly', () async {
      // 1. Create product
      final product = ProductModel(
        name: 'Organic Milk',
        price: 45.0,
        createdAt: DateTime.now(),
      );
      final created = await productRepo.createProduct(product);
      expect(created.id, isNotNull);
      expect(created.name, 'Organic Milk');
      expect(created.price, 45.0);

      // 2. Search product
      final searchResults = await productRepo.searchProducts('organic');
      expect(searchResults.length, 1);
      expect(searchResults.first.name, 'Organic Milk');

      // 3. Update product
      final updated = created.copyWith(price: 50.0);
      await productRepo.updateProduct(updated);
      final all = await productRepo.getAllProducts();
      expect(all.first.price, 50.0);

      // 4. Delete product
      await productRepo.deleteProduct(created.id!);
      final afterDelete = await productRepo.getAllProducts();
      expect(afterDelete, isEmpty);
    });

    test('Bill creation and item snapshots are preserved immutably', () async {
      final now = DateTime(2026, 8, 26, 10, 30);
      final invNumber = await billingRepo.generateNextInvoiceNumber(now);
      expect(invNumber, 'INV-20260826-0001');

      final bill = BillModel(
        invoiceNumber: invNumber,
        customerName: 'John Doe',
        customerPhone: '9876543210',
        subtotal: 100.0,
        discountPercent: 10.0,
        discountAmount: 10.0,
        taxPercent: 5.0,
        taxAmount: 4.5,
        totalAmount: 94.5,
        createdAt: now,
      );

      final items = [
        BillItemModel(
          productName: 'Widget A',
          unitPrice: 50.0,
          quantity: 2,
          totalPrice: 100.0,
        ),
      ];

      final saved = await billingRepo.createBill(bill, items);
      expect(saved.id, isNotNull);
      expect(saved.items.length, 1);
      expect(saved.items.first.productName, 'Widget A');

      // Verify sequence increments for next bill on same date
      final nextInvNumber = await billingRepo.generateNextInvoiceNumber(now);
      expect(nextInvNumber, 'INV-20260826-0002');

      // Fetch with items
      final retrieved = await billingRepo.getBillWithItems(saved.id!);
      expect(retrieved, isNotNull);
      expect(retrieved!.customerName, 'John Doe');
      expect(retrieved.items.length, 1);
      expect(retrieved.items.first.totalPrice, 100.0);
    });

    test('Bill update replaces item snapshots inside transaction', () async {
      final now = DateTime.now();
      final bill = BillModel(
        invoiceNumber: 'INV-20260826-0001',
        customerName: 'Alice',
        subtotal: 50.0,
        totalAmount: 50.0,
        createdAt: now,
      );
      final items = [
        BillItemModel(productName: 'Bread', unitPrice: 50.0, quantity: 1, totalPrice: 50.0),
      ];
      final saved = await billingRepo.createBill(bill, items);

      // Update bill with new items
      final updatedBill = saved.copyWith(
        subtotal: 80.0,
        totalAmount: 80.0,
        updatedAt: DateTime.now(),
      );
      final newItems = [
        BillItemModel(productName: 'Bread', unitPrice: 50.0, quantity: 1, totalPrice: 50.0),
        BillItemModel(productName: 'Butter', unitPrice: 30.0, quantity: 1, totalPrice: 30.0),
      ];

      final updated = await billingRepo.updateBill(updatedBill, newItems);
      expect(updated.items.length, 2);

      final reloaded = await billingRepo.getBillWithItems(saved.id!);
      expect(reloaded!.items.length, 2);
      expect(reloaded.totalAmount, 80.0);
    });

    test('Date-filtered billing history query works', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      await billingRepo.createBill(
        BillModel(
          invoiceNumber: 'INV-20260825-0001',
          subtotal: 50.0,
          totalAmount: 50.0,
          createdAt: yesterday,
        ),
        [],
      );

      await billingRepo.createBill(
        BillModel(
          invoiceNumber: 'INV-20260826-0001',
          subtotal: 150.0,
          totalAmount: 150.0,
          createdAt: today,
        ),
        [],
      );

      // Query all
      final allBills = await historyRepo.getBills();
      expect(allBills.length, 2);

      // Query only today
      final startToday = DateTime(today.year, today.month, today.day, 0, 0, 0);
      final endToday = DateTime(today.year, today.month, today.day, 23, 59, 59);
      final todayBills = await historyRepo.getBills(
        startDate: startToday,
        endDate: endToday,
      );
      expect(todayBills.length, 1);
      expect(todayBills.first.invoiceNumber, 'INV-20260826-0001');
    });

    test('Delete bill deletes items and header', () async {
      final bill = await billingRepo.createBill(
        BillModel(
          invoiceNumber: 'INV-20260826-0099',
          subtotal: 100.0,
          totalAmount: 100.0,
          createdAt: DateTime.now(),
        ),
        [
          BillItemModel(productName: 'Item', unitPrice: 100.0, quantity: 1, totalPrice: 100.0),
        ],
      );

      await billingRepo.deleteBill(bill.id!);
      final check = await billingRepo.getBillWithItems(bill.id!);
      expect(check, isNull);
    });

    test('Settings repository creates and persists default and updated values', () async {
      final settings = await settingsRepo.getSettings();
      expect(settings.id, 1);
      expect(settings.businessName, "BROTHER'S AUTO CARE");
      expect(settings.phoneNumber, '78 71 75 78 78');

      await settingsRepo.updateSettings(
        const BusinessSettingsModel(
          id: 1,
          businessName: "BROTHER'S AUTO CARE",
          phoneNumber: '9988776655',
          address: 'Main Street, Udumalpet',
          taxEnabled: true,
          taxPercent: 12.0,
        ),
      );

      final updated = await settingsRepo.getSettings();
      expect(updated.businessName, "BROTHER'S AUTO CARE");
      expect(updated.phoneNumber, '9988776655');
      expect(updated.address, 'Main Street, Udumalpet');
      expect(updated.taxEnabled, isTrue);
      expect(updated.taxPercent, 12.0);
    });
  });
}
