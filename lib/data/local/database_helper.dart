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
  static const int _databaseVersion = 1;

  // ─── Table name ──────────────────────────────────────────────────────────
  static const String tableTransactions = 'transactions';

  // ─── Column names ────────────────────────────────────────────────────────
  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colAmount = 'amount';
  static const String colType = 'type';
  static const String colPaymentMode = 'paymentMode';
  static const String colDate = 'date';
  static const String colTime = 'time';
  static const String colCreatedAt = 'createdAt';
  static const String colUpdatedAt = 'updatedAt';

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
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createTransactionsTableSql);
  }

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
}
