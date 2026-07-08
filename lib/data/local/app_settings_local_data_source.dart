import 'package:sqflite/sqflite.dart';
import '../../domain/entities/app_settings.dart';
import 'database_helper.dart';

/// SQLite data source for [AppSettings].
///
/// Only one settings row is ever written (id = 1).
/// All read/write operations target that single row.
class AppSettingsLocalDataSource {
  const AppSettingsLocalDataSource(this._db);

  final Database _db;

  // ─── Read ─────────────────────────────────────────────────────────────────

  /// Returns the settings row, or `null` if no row exists yet.
  Future<AppSettings?> fetchSettings() async {
    final rows = await _db.query(
      DatabaseHelper.tableAppSettings,
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return _rowToEntity(rows.first);
  }

  // ─── Write ────────────────────────────────────────────────────────────────

  /// Inserts the initial settings row produced during first-launch setup.
  Future<void> insertSettings({
    required double initialCash,
    required double initialDigital,
  }) async {
    final now = DateTime.now().toIso8601String();
    await _db.insert(
      DatabaseHelper.tableAppSettings,
      {
        DatabaseHelper.colId: 1,
        DatabaseHelper.colInitialCash: initialCash,
        DatabaseHelper.colInitialDigital: initialDigital,
        DatabaseHelper.colIsFirstLaunch: 0, // false — setup is complete
        DatabaseHelper.colCreatedAt: now,
        DatabaseHelper.colUpdatedAt: now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Sets [isFirstLaunch] to 0 (false) for the existing settings row.
  Future<void> markFirstLaunchComplete() async {
    final now = DateTime.now().toIso8601String();
    await _db.update(
      DatabaseHelper.tableAppSettings,
      {
        DatabaseHelper.colIsFirstLaunch: 0,
        DatabaseHelper.colUpdatedAt: now,
      },
      where: '${DatabaseHelper.colId} = ?',
      whereArgs: [1],
    );
  }

  // ─── Mapper ───────────────────────────────────────────────────────────────

  AppSettings _rowToEntity(Map<String, dynamic> row) {
    return AppSettings(
      id: row[DatabaseHelper.colId] as int,
      initialCash: (row[DatabaseHelper.colInitialCash] as num).toDouble(),
      initialDigital: (row[DatabaseHelper.colInitialDigital] as num).toDouble(),
      isFirstLaunch: (row[DatabaseHelper.colIsFirstLaunch] as int) == 1,
      createdAt: row[DatabaseHelper.colCreatedAt] as String,
      updatedAt: row[DatabaseHelper.colUpdatedAt] as String,
    );
  }
}
