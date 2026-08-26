import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_constants.dart';
import 'database_migrations.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _database;
  static bool _ffiInitialized = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Database get db {
    if (_database == null) {
      throw StateError('Database has not been initialized. Ensure AppDatabase.instance.database is awaited first.');
    }
    return _database!;
  }

  static void initializeFfiIfDesktop() {
    if (_ffiInitialized) return;
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _ffiInitialized = true;
    }
  }

  Future<Database> _initDatabase() async {
    initializeFfiIfDesktop();

    String dbPath;
    if (!kIsWeb && Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'] ?? Platform.environment['APPDATA'] ?? '.';
      final appDir = Directory(p.join(userProfile, 'Documents', 'BillingApp', 'Data'));
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }
      dbPath = p.join(appDir.path, DatabaseConstants.databaseName);
    } else if (!kIsWeb && (Platform.isLinux || Platform.isMacOS)) {
      final docDir = await getApplicationDocumentsDirectory();
      final appDir = Directory(p.join(docDir.path, 'BillingApp', 'Data'));
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }
      dbPath = p.join(appDir.path, DatabaseConstants.databaseName);
    } else {
      final defaultDatabasesPath = await getDatabasesPath();
      dbPath = p.join(defaultDatabasesPath, DatabaseConstants.databaseName);
    }

    final factory =
        (!kIsWeb &&
            (Platform.isWindows || Platform.isLinux || Platform.isMacOS))
        ? databaseFactoryFfi
        : databaseFactory;

    return await factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: DatabaseConstants.databaseVersion,
        onCreate: DatabaseMigrations.onCreate,
        onUpgrade: DatabaseMigrations.onUpgrade,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
