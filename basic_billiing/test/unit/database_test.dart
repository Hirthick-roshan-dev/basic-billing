import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:basic_billiing/core/database/database_constants.dart';
import 'package:basic_billiing/core/database/database_migrations.dart';
import 'package:basic_billiing/features/billing/model/bill_model.dart';
import 'package:basic_billiing/features/billing/model/bill_item_model.dart';
import 'package:basic_billiing/features/billing/model/product_model.dart';
import 'package:basic_billiing/features/billing/repo/billing_repository.dart';
import 'package:basic_billiing/features/billing/repo/offer_repository.dart';
import 'package:basic_billiing/features/billing/repo/product_repository.dart';
import 'package:basic_billiing/features/billing_history/repo/billing_history_repository.dart';
import 'package:basic_billiing/features/settings/model/business_settings_model.dart';
import 'package:basic_billiing/features/settings/repo/settings_repository.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late ProductRepository productRepo;
  late OfferRepository offerRepo;
  late BillingRepository billingRepo;
  late BillingHistoryRepository historyRepo;
  late SettingsRepository settingsRepo;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseConstants.databaseVersion,
        onCreate: DatabaseMigrations.onCreate,
        onUpgrade: DatabaseMigrations.onUpgrade,
      ),
    );

    productRepo = ProductRepository(db: db);
    offerRepo = OfferRepository(db: db);
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
        vehicleNumber: 'TN 38 AB 1234',
        vehicleModel: 'Swift',
        km: '45000',
        jobCardNumber: 'JC-1024',
        paymentType: 'UPI',
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
      expect(saved.vehicleNumber, 'TN 38 AB 1234');
      expect(saved.vehicleModel, 'Swift');
      expect(saved.km, '45000');
      expect(saved.jobCardNumber, 'JC-1024');
      expect(saved.paymentType, 'UPI');

      // Verify sequence increments for next bill on same date
      final nextInvNumber = await billingRepo.generateNextInvoiceNumber(now);
      expect(nextInvNumber, 'INV-20260826-0002');

      // Fetch with items
      final retrieved = await billingRepo.getBillWithItems(saved.id!);
      expect(retrieved, isNotNull);
      expect(retrieved!.customerName, 'John Doe');
      expect(retrieved.vehicleNumber, 'TN 38 AB 1234');
      expect(retrieved.vehicleModel, 'Swift');
      expect(retrieved.km, '45000');
      expect(retrieved.jobCardNumber, 'JC-1024');
      expect(retrieved.paymentType, 'UPI');
      expect(retrieved.items.length, 1);
      expect(retrieved.items.first.totalPrice, 100.0);
    });

    test('Bill update replaces item snapshots inside transaction', () async {
      final now = DateTime.now();
      final bill = BillModel(
        invoiceNumber: 'INV-20260826-0001',
        customerName: 'Alice',
        vehicleNumber: 'TN 38 AB 1234',
        vehicleModel: 'Swift',
        km: '45000',
        jobCardNumber: 'JC-1024',
        paymentType: 'Cash',
        subtotal: 50.0,
        totalAmount: 50.0,
        createdAt: now,
      );
      final items = [
        BillItemModel(productName: 'Bread', unitPrice: 50.0, quantity: 1, totalPrice: 50.0),
      ];
      final saved = await billingRepo.createBill(bill, items);

      // Update bill with new items and updated vehicle number & payment type
      final updatedBill = saved.copyWith(
        vehicleNumber: 'TN 38 CD 5678',
        vehicleModel: 'Creta',
        km: '52000',
        paymentType: 'UPI',
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
      expect(updated.vehicleNumber, 'TN 38 CD 5678');
      expect(updated.vehicleModel, 'Creta');
      expect(updated.km, '52000');
      expect(updated.paymentType, 'UPI');

      final reloaded = await billingRepo.getBillWithItems(saved.id!);
      expect(reloaded!.items.length, 2);
      expect(reloaded.totalAmount, 80.0);
      expect(reloaded.vehicleNumber, 'TN 38 CD 5678');
      expect(reloaded.vehicleModel, 'Creta');
      expect(reloaded.km, '52000');
      expect(reloaded.jobCardNumber, 'JC-1024');
      expect(reloaded.paymentType, 'UPI');
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

    test('Migration from v2 to v3 safely adds vehicle_number and job_card_no columns', () async {
      // 1. Create a v2 database schema directly
      final v2Db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE bills (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                invoiceNumber TEXT UNIQUE,
                customer_name TEXT,
                customer_phone TEXT,
                subtotal REAL NOT NULL,
                discount_percent REAL DEFAULT 0,
                discount_amount REAL DEFAULT 0,
                tax_percent REAL DEFAULT 0,
                tax_amount REAL DEFAULT 0,
                total_amount REAL NOT NULL,
                is_total_edited INTEGER DEFAULT 0,
                created_at TEXT NOT NULL,
                updated_at TEXT
              )
            ''');
            await db.insert('bills', {
              'invoiceNumber': 'INV-OLD-001',
              'customer_name': 'Existing Customer',
              'subtotal': 500.0,
              'total_amount': 500.0,
              'created_at': DateTime.now().toIso8601String(),
            });
          },
        ),
      );

      // 2. Perform upgrade from v2 to v3
      await DatabaseMigrations.onUpgrade(v2Db, 2, 3);

      // 3. Query existing bill and verify columns exist and are null without crash
      final rows = await v2Db.query('bills');
      expect(rows.length, 1);
      expect(rows.first['customer_name'], 'Existing Customer');
      expect(rows.first.containsKey('vehicle_number'), isTrue);
      expect(rows.first['vehicle_number'], isNull);
      expect(rows.first.containsKey('job_card_no'), isTrue);
      expect(rows.first['job_card_no'], isNull);

      // 4. Insert new bill into upgraded database with vehicle & job card numbers
      await v2Db.insert('bills', {
        'invoiceNumber': 'INV-NEW-002',
        'customer_name': 'New Customer',
        'vehicle_number': 'TN 38 AB 9999',
        'job_card_no': 'JC-2048',
        'subtotal': 800.0,
        'total_amount': 800.0,
        'created_at': DateTime.now().toIso8601String(),
      });

      final allRows = await v2Db.query('bills');
      expect(allRows.length, 2);
      expect(allRows.last['vehicle_number'], 'TN 38 AB 9999');
      expect(allRows.last['job_card_no'], 'JC-2048');

      await v2Db.close();
    });

    test('Migration from v4 to v5 safely adds payment_type column with default Cash', () async {
      // 1. Create a v4 database schema
      final v4Db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 4,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE bills (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                invoice_number TEXT UNIQUE,
                customer_name TEXT,
                vehicle_number TEXT,
                vehicle_model TEXT,
                km TEXT,
                job_card_no TEXT,
                subtotal REAL NOT NULL,
                total_amount REAL NOT NULL,
                created_at TEXT NOT NULL
              )
            ''');
            await db.insert('bills', {
              'invoice_number': 'INV-V4-001',
              'customer_name': 'V4 Customer',
              'subtotal': 500.0,
              'total_amount': 500.0,
              'created_at': DateTime.now().toIso8601String(),
            });
          },
        ),
      );

      // 2. Upgrade from v4 to v5
      await DatabaseMigrations.onUpgrade(v4Db, 4, 5);

      // 3. Query existing bill and verify payment_type exists and defaults to Cash
      final rows = await v4Db.query('bills');
      expect(rows.length, 1);
      expect(rows.first['customer_name'], 'V4 Customer');
      expect(rows.first.containsKey('payment_type'), isTrue);
      expect(rows.first['payment_type'], 'Cash');

      // 4. Insert new bill with UPI payment type
      await v4Db.insert('bills', {
        'invoice_number': 'INV-V5-002',
        'customer_name': 'V5 Customer',
        'payment_type': 'UPI',
        'subtotal': 1200.0,
        'total_amount': 1200.0,
        'created_at': DateTime.now().toIso8601String(),
      });

      final allRows = await v4Db.query('bills');
      expect(allRows.length, 2);
      expect(allRows.first['payment_type'], 'Cash');
      expect(allRows.last['payment_type'], 'UPI');

      await v4Db.close();
    });

    test('Offer products CRUD operations work properly across 3 offer groups', () async {
      final p1 = ProductModel(
        id: 10,
        name: 'Oil Filter',
        price: 250.0,
        createdAt: DateTime.now(),
      );
      final p2 = ProductModel(
        id: 11,
        name: 'Brake Pads',
        price: 850.0,
        createdAt: DateTime.now(),
      );
      final p3 = ProductModel(
        id: 12,
        name: 'Engine Oil',
        price: 1200.0,
        createdAt: DateTime.now(),
      );

      // 1. Add offer products to distinct groups (Offer 1, Offer 2, Offer 3)
      await offerRepo.addOfferProduct(p1, offerGroup: 1);
      await offerRepo.addOfferProduct(p2, offerGroup: 1);
      await offerRepo.addOfferProduct(p2, offerGroup: 2); // p2 in both Offer 1 and Offer 2
      await offerRepo.addOfferProduct(p3, offerGroup: 3);

      // 2. Verify lists per group
      final offers1 = await offerRepo.getOfferProducts(offerGroup: 1);
      expect(offers1.length, 2);
      expect(await offerRepo.isOfferProduct('Oil Filter', offerGroup: 1), isTrue);
      expect(await offerRepo.isOfferProduct('Brake Pads', offerGroup: 1), isTrue);
      expect(await offerRepo.isOfferProduct('Engine Oil', offerGroup: 1), isFalse);

      final offers2 = await offerRepo.getOfferProducts(offerGroup: 2);
      expect(offers2.length, 1);
      expect(offers2.first.name, 'Brake Pads');

      final offers3 = await offerRepo.getOfferProducts(offerGroup: 3);
      expect(offers3.length, 1);
      expect(offers3.first.name, 'Engine Oil');

      // 3. Verify getOfferGroupsForProduct
      final groupsForBrakePads = await offerRepo.getOfferGroupsForProduct('Brake Pads');
      expect(groupsForBrakePads.contains(1), isTrue);
      expect(groupsForBrakePads.contains(2), isTrue);
      expect(groupsForBrakePads.contains(3), isFalse);

      // 4. Remove offer product from specific group
      await offerRepo.removeOfferProduct('Brake Pads', offerGroup: 1);
      final updatedOffers1 = await offerRepo.getOfferProducts(offerGroup: 1);
      expect(updatedOffers1.length, 1);
      expect(updatedOffers1.first.name, 'Oil Filter');
      // Offer 2 still has Brake Pads
      expect(await offerRepo.isOfferProduct('Brake Pads', offerGroup: 2), isTrue);

      // 5. Clear all offers in group 2
      await offerRepo.clearOfferProducts(offerGroup: 2);
      final emptyOffers2 = await offerRepo.getOfferProducts(offerGroup: 2);
      expect(emptyOffers2.isEmpty, isTrue);
    });

    test('Offer products are listed in insertion order (first added first, last added last)', () async {
      await offerRepo.clearOfferProducts(offerGroup: 4);

      final pZ = ProductModel(id: 101, name: 'Zebra Product', price: 100.0, createdAt: DateTime.now());
      final pA = ProductModel(id: 102, name: 'Alpha Product', price: 200.0, createdAt: DateTime.now());
      final pM = ProductModel(id: 103, name: 'Middle Product', price: 300.0, createdAt: DateTime.now());

      // Insert in order: Z -> A -> M
      await offerRepo.addOfferProduct(pZ, offerGroup: 4);
      await offerRepo.addOfferProduct(pA, offerGroup: 4);
      await offerRepo.addOfferProduct(pM, offerGroup: 4);

      final products = await offerRepo.getOfferProducts(offerGroup: 4);
      expect(products.length, 3);
      expect(products[0].name, 'Zebra Product');
      expect(products[1].name, 'Alpha Product');
      expect(products[2].name, 'Middle Product');
    });

    test('Migration from v5 to v6 safely creates offer_products table', () async {
      final v5Db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 5,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE bills (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                invoice_number TEXT UNIQUE,
                payment_type TEXT DEFAULT 'Cash',
                subtotal REAL NOT NULL,
                total_amount REAL NOT NULL,
                created_at TEXT NOT NULL
              )
            ''');
          },
        ),
      );

      // Upgrade from v5 to v6
      await DatabaseMigrations.onUpgrade(v5Db, 5, 6);

      // Insert and query offer products on upgraded db
      final v6OfferRepo = OfferRepository(db: v5Db);
      await v6OfferRepo.addOfferProduct(
        ProductModel(name: 'Coolant', price: 300.0, createdAt: DateTime.now()),
      );

      final offers = await v6OfferRepo.getOfferProducts();
      expect(offers.length, 1);
      expect(offers.first.name, 'Coolant');

      await v5Db.close();
    });

    test('Migration from v6 to v7 safely adds offer_group column to offer_products table', () async {
      final v6Db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 6,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE offer_products (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                product_id INTEGER,
                product_name TEXT NOT NULL UNIQUE,
                product_price REAL NOT NULL,
                created_at TEXT NOT NULL
              )
            ''');
            await db.insert('offer_products', {
              'product_name': 'Legacy Offer Product',
              'product_price': 150.0,
              'created_at': DateTime.now().toIso8601String(),
            });
          },
        ),
      );

      // Upgrade from v6 to v7
      await DatabaseMigrations.onUpgrade(v6Db, 6, 7);

      // Verify existing items default to offer_group 1
      final v7OfferRepo = OfferRepository(db: v6Db);
      final offersGroup1 = await v7OfferRepo.getOfferProducts(offerGroup: 1);
      expect(offersGroup1.length, 1);
      expect(offersGroup1.first.name, 'Legacy Offer Product');

      // Add item to offer group 2 on upgraded database
      await v7OfferRepo.addOfferProduct(
        ProductModel(name: 'New V7 Product', price: 500.0, createdAt: DateTime.now()),
        offerGroup: 2,
      );

      final offersGroup2 = await v7OfferRepo.getOfferProducts(offerGroup: 2);
      expect(offersGroup2.length, 1);
      expect(offersGroup2.first.name, 'New V7 Product');

      await v6Db.close();
    });

    test('Offer group total prices get and set correctly', () async {
      // Default should be 0.0
      final defaultPrice = await offerRepo.getOfferGroupTotalPrice(1);
      expect(defaultPrice, 0.0);

      // Set total price for Offer 1 and Offer 2
      await offerRepo.setOfferGroupTotalPrice(1, 999.0);
      await offerRepo.setOfferGroupTotalPrice(2, 1499.5);

      expect(await offerRepo.getOfferGroupTotalPrice(1), 999.0);
      expect(await offerRepo.getOfferGroupTotalPrice(2), 1499.5);
      expect(await offerRepo.getOfferGroupTotalPrice(3), 0.0);
      expect(await offerRepo.getOfferGroupTotalPrice(4), 0.0);
    });

    test('Migration from v7 to v8 safely creates offer_groups table with seeded defaults', () async {
      final v7Db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 7,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE offer_products (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                offer_group INTEGER NOT NULL DEFAULT 1,
                product_id INTEGER,
                product_name TEXT NOT NULL,
                product_price REAL NOT NULL,
                created_at TEXT NOT NULL,
                UNIQUE(offer_group, product_name)
              )
            ''');
          },
        ),
      );

      // Upgrade from v7 to v8
      await DatabaseMigrations.onUpgrade(v7Db, 7, 8);

      final v8OfferRepo = OfferRepository(db: v7Db);
      // Verify default seeded offer groups
      expect(await v8OfferRepo.getOfferGroupTotalPrice(1), 0.0);
      expect(await v8OfferRepo.getOfferGroupTotalPrice(2), 0.0);
      expect(await v8OfferRepo.getOfferGroupTotalPrice(3), 0.0);
      expect(await v8OfferRepo.getOfferGroupTotalPrice(4), 0.0);

      // Verify updating offer total price works on upgraded db
      await v8OfferRepo.setOfferGroupTotalPrice(1, 799.0);
      expect(await v8OfferRepo.getOfferGroupTotalPrice(1), 799.0);

      await v7Db.close();
    });
  });
}
