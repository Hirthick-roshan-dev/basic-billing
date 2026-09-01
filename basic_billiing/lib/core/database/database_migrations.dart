import 'package:sqflite/sqflite.dart';
import 'database_constants.dart';

class DatabaseMigrations {
  DatabaseMigrations._();

  static Future<void> onCreate(Database db, int version) async {
    // Products Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableProducts} (
        ${DatabaseConstants.colProductId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colProductName} TEXT NOT NULL,
        ${DatabaseConstants.colProductPrice} REAL NOT NULL,
        ${DatabaseConstants.colProductCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colProductUpdatedAt} TEXT
      )
    ''');

    // Bills Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableBills} (
        ${DatabaseConstants.colBillId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colBillInvoiceNumber} TEXT UNIQUE NOT NULL,
        ${DatabaseConstants.colBillCustomerName} TEXT,
        ${DatabaseConstants.colBillCustomerPhone} TEXT,
        ${DatabaseConstants.colBillVehicleNumber} TEXT,
        ${DatabaseConstants.colBillVehicleModel} TEXT,
        ${DatabaseConstants.colBillKm} TEXT,
        ${DatabaseConstants.colBillJobCardNumber} TEXT,
        ${DatabaseConstants.colBillPaymentType} TEXT DEFAULT 'Cash',
        ${DatabaseConstants.colBillSubtotal} REAL NOT NULL,
        ${DatabaseConstants.colBillDiscountPercent} REAL DEFAULT 0,
        ${DatabaseConstants.colBillDiscountAmount} REAL DEFAULT 0,
        ${DatabaseConstants.colBillTaxPercent} REAL DEFAULT 0,
        ${DatabaseConstants.colBillTaxAmount} REAL DEFAULT 0,
        ${DatabaseConstants.colBillTotalAmount} REAL NOT NULL,
        ${DatabaseConstants.colBillIsTotalEdited} INTEGER DEFAULT 0,
        ${DatabaseConstants.colBillCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colBillUpdatedAt} TEXT
      )
    ''');

    // Bill Items Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableBillItems} (
        ${DatabaseConstants.colBillItemId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colBillItemBillId} INTEGER NOT NULL,
        ${DatabaseConstants.colBillItemProductName} TEXT NOT NULL,
        ${DatabaseConstants.colBillItemUnitPrice} REAL NOT NULL,
        ${DatabaseConstants.colBillItemQuantity} INTEGER NOT NULL,
        ${DatabaseConstants.colBillItemTotalPrice} REAL NOT NULL,
        FOREIGN KEY (${DatabaseConstants.colBillItemBillId}) REFERENCES ${DatabaseConstants.tableBills} (${DatabaseConstants.colBillId}) ON DELETE CASCADE
      )
    ''');

    // Business Settings Table (Fixed id = 1)
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableBusinessSettings} (
        ${DatabaseConstants.colSettingsId} INTEGER PRIMARY KEY,
        ${DatabaseConstants.colSettingsBusinessName} TEXT,
        ${DatabaseConstants.colSettingsPhoneNumber} TEXT,
        ${DatabaseConstants.colSettingsAddress} TEXT,
        ${DatabaseConstants.colSettingsTaxEnabled} INTEGER DEFAULT 0,
        ${DatabaseConstants.colSettingsTaxPercent} REAL DEFAULT 0,
        ${DatabaseConstants.colSettingsUpdatedAt} TEXT
      )
    ''');

    // Offer Products Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableOfferProducts} (
        ${DatabaseConstants.colOfferId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colOfferGroup} INTEGER NOT NULL DEFAULT 1,
        ${DatabaseConstants.colOfferProductId} INTEGER,
        ${DatabaseConstants.colOfferProductName} TEXT NOT NULL,
        ${DatabaseConstants.colOfferProductPrice} REAL NOT NULL,
        ${DatabaseConstants.colOfferCreatedAt} TEXT NOT NULL,
        UNIQUE(${DatabaseConstants.colOfferGroup}, ${DatabaseConstants.colOfferProductName})
      )
    ''');

    // Offer Groups Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableOfferGroups} (
        ${DatabaseConstants.colOfferGroupId} INTEGER PRIMARY KEY,
        ${DatabaseConstants.colOfferGroupName} TEXT NOT NULL,
        ${DatabaseConstants.colOfferGroupTotalPrice} REAL NOT NULL DEFAULT 0.0,
        ${DatabaseConstants.colOfferGroupUpdatedAt} TEXT
      )
    ''');

    for (int g = 1; g <= 4; g++) {
      await db.insert(DatabaseConstants.tableOfferGroups, {
        DatabaseConstants.colOfferGroupId: g,
        DatabaseConstants.colOfferGroupName: 'Offer $g',
        DatabaseConstants.colOfferGroupTotalPrice: 0.0,
        DatabaseConstants.colOfferGroupUpdatedAt: DateTime.now().toIso8601String(),
      });
    }

    // Seed default settings for BROTHER'S AUTO CARE
    await db.insert(DatabaseConstants.tableBusinessSettings, {
      DatabaseConstants.colSettingsId: 1,
      DatabaseConstants.colSettingsBusinessName: "BROTHER'S AUTO CARE",
      DatabaseConstants.colSettingsPhoneNumber: '78 71 75 78 78',
      DatabaseConstants.colSettingsAddress:
          'No.1, Park Avenue, Near Aravind Eye Hospital, Udumalpet - 642126',
      DatabaseConstants.colSettingsTaxEnabled: 0,
      DatabaseConstants.colSettingsTaxPercent: 0.0,
      DatabaseConstants.colSettingsUpdatedAt: DateTime.now().toIso8601String(),
    });
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Add address column if upgrading from v1
      try {
        await db.execute(
          'ALTER TABLE ${DatabaseConstants.tableBusinessSettings} ADD COLUMN ${DatabaseConstants.colSettingsAddress} TEXT',
        );
      } catch (_) {}

      // Update business info to BROTHER'S AUTO CARE
      await db.update(
        DatabaseConstants.tableBusinessSettings,
        {
          DatabaseConstants.colSettingsBusinessName: "BROTHER'S AUTO CARE",
          DatabaseConstants.colSettingsPhoneNumber: '78 71 75 78 78',
          DatabaseConstants.colSettingsAddress:
              'No.1, Park Avenue, Near Aravind Eye Hospital, Udumalpet - 642126',
          DatabaseConstants.colSettingsUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '${DatabaseConstants.colSettingsId} = ?',
        whereArgs: [1],
      );
    }

    if (oldVersion < 3) {
      // Add vehicle_number and job_card_no columns to bills table (nullable so existing data is safe)
      try {
        await db.execute(
          'ALTER TABLE ${DatabaseConstants.tableBills} ADD COLUMN ${DatabaseConstants.colBillVehicleNumber} TEXT',
        );
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE ${DatabaseConstants.tableBills} ADD COLUMN ${DatabaseConstants.colBillJobCardNumber} TEXT',
        );
      } catch (_) {}
    }

    if (oldVersion < 4) {
      // Add vehicle_model and km columns to bills table (nullable so existing data is safe)
      try {
        await db.execute(
          'ALTER TABLE ${DatabaseConstants.tableBills} ADD COLUMN ${DatabaseConstants.colBillVehicleModel} TEXT',
        );
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE ${DatabaseConstants.tableBills} ADD COLUMN ${DatabaseConstants.colBillKm} TEXT',
        );
      } catch (_) {}
    }

    if (oldVersion < 5) {
      // Add payment_type column to bills table (default 'Cash', safe for existing data)
      try {
        await db.execute(
          "ALTER TABLE ${DatabaseConstants.tableBills} ADD COLUMN ${DatabaseConstants.colBillPaymentType} TEXT DEFAULT 'Cash'",
        );
      } catch (_) {}
    }

    if (oldVersion < 6) {
      // Add offer_products table
      try {
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
      } catch (_) {}
    }

    if (oldVersion < 7) {
      // Add offer_group column to offer_products if upgrading from v6
      try {
        await db.execute(
          'ALTER TABLE ${DatabaseConstants.tableOfferProducts} ADD COLUMN ${DatabaseConstants.colOfferGroup} INTEGER DEFAULT 1',
        );
      } catch (_) {}
    }

    if (oldVersion < 8) {
      // Add offer_groups table if upgrading from v7
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableOfferGroups} (
            ${DatabaseConstants.colOfferGroupId} INTEGER PRIMARY KEY,
            ${DatabaseConstants.colOfferGroupName} TEXT NOT NULL,
            ${DatabaseConstants.colOfferGroupTotalPrice} REAL NOT NULL DEFAULT 0.0,
            ${DatabaseConstants.colOfferGroupUpdatedAt} TEXT
          )
        ''');
        for (int g = 1; g <= 4; g++) {
          await db.insert(
            DatabaseConstants.tableOfferGroups,
            {
              DatabaseConstants.colOfferGroupId: g,
              DatabaseConstants.colOfferGroupName: 'Offer $g',
              DatabaseConstants.colOfferGroupTotalPrice: 0.0,
              DatabaseConstants.colOfferGroupUpdatedAt: DateTime.now().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      } catch (_) {}
    }
  }
}
