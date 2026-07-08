import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database helper for the Expense Notebook application.
///
/// Implements the singleton pattern so only one database connection
/// is opened throughout the application lifecycle.
class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  static const String _databaseName = 'expense_tracker.db';
  static const int _databaseVersion = 2;

  // ─── Table names ─────────────────────────────────────────────────────────
  static const String tableTransactions = 'transactions';
  static const String tableAppSettings = 'app_settings';

  // ─── transactions columns ─────────────────────────────────────────────────
  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colAmount = 'amount';
  static const String colType = 'type';
  static const String colPaymentMode = 'paymentMode';
  static const String colDate = 'date';
  static const String colTime = 'time';
  static const String colCreatedAt = 'createdAt';
  static const String colUpdatedAt = 'updatedAt';

  // ─── app_settings columns ────────────────────────────────────────────────
  static const String colInitialCash = 'initialCash';
  static const String colInitialDigital = 'initialDigital';
  static const String colIsFirstLaunch = 'isFirstLaunch';

  /// Returns the open database, initialising it on first access.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createTransactionsTableSql);
    await db.execute(_createAppSettingsTableSql);
  }

  /// Handles schema migrations for future database version bumps.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migrations will be added here as new versions are introduced.
  }

  // ─── DDL ─────────────────────────────────────────────────────────────────

  static const String _createTransactionsTableSql = '''
    CREATE TABLE $tableTransactions (
      $colId          INTEGER PRIMARY KEY AUTOINCREMENT,
      $colTitle       TEXT    NOT NULL,
      $colAmount      REAL    NOT NULL,
      $colType        TEXT    NOT NULL,
      $colPaymentMode TEXT    NOT NULL,
      $colDate        TEXT    NOT NULL,
      $colTime        TEXT    NOT NULL,
      $colCreatedAt   TEXT    NOT NULL,
      $colUpdatedAt   TEXT    NOT NULL
    )
  ''';

  /// Stores application-level settings including the first-launch flag
  /// and initial balance seeds. Only one row is ever written (id = 1).
  static const String _createAppSettingsTableSql = '''
    CREATE TABLE $tableAppSettings (
      $colId             INTEGER PRIMARY KEY,
      $colInitialCash    REAL    NOT NULL,
      $colInitialDigital REAL    NOT NULL,
      $colIsFirstLaunch  INTEGER NOT NULL,
      $colCreatedAt      TEXT    NOT NULL,
      $colUpdatedAt      TEXT    NOT NULL
    )
  ''';
}

