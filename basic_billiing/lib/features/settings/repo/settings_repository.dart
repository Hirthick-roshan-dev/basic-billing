import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_constants.dart';
import '../model/business_settings_model.dart';

abstract class ISettingsRepository {
  Future<BusinessSettingsModel> getSettings();
  Future<void> updateSettings(BusinessSettingsModel settings);
}

class SettingsRepository implements ISettingsRepository {
  final Database db;

  SettingsRepository({required this.db});

  @override
  Future<BusinessSettingsModel> getSettings() async {
    final rows = await db.query(
      DatabaseConstants.tableBusinessSettings,
      where: '${DatabaseConstants.colSettingsId} = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isNotEmpty) {
      return BusinessSettingsModel.fromMap(rows.first);
    }

    // Default fallback
    const defaultSettings = BusinessSettingsModel();
    await db.insert(
      DatabaseConstants.tableBusinessSettings,
      defaultSettings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return defaultSettings;
  }

  @override
  Future<void> updateSettings(BusinessSettingsModel settings) async {
    await db.insert(
      DatabaseConstants.tableBusinessSettings,
      settings.copyWith(id: 1, updatedAt: DateTime.now()).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
