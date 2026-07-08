import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';

/// Provides application startup helpers.
///
/// Reads the [DatabaseHelper.tableAppSettings] table to determine
/// the correct startup route without containing any business logic.
///
/// Usage (called from SplashScreen):
/// ```dart
/// final helper = AppStartupHelper(db);
/// final isFirst = await helper.isFirstLaunch();
/// ```
class AppStartupHelper {
  const AppStartupHelper(this._db);

  final Database _db;

  /// Returns `true` when no settings row exists or [isFirstLaunch] == 1.
  ///
  /// Phase 1 will insert the settings row after the user completes
  /// the Initial Setup screen. Until then this always returns `true`.
  Future<bool> isFirstLaunch() async {
    final rows = await _db.query(
      DatabaseHelper.tableAppSettings,
      columns: [DatabaseHelper.colIsFirstLaunch],
      limit: 1,
    );

    if (rows.isEmpty) return true;

    final value = rows.first[DatabaseHelper.colIsFirstLaunch];
    return value == null || value == 1;
  }
}
