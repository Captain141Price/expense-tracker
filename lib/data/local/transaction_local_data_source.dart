import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/transaction_entry.dart';
import '../../domain/enums/payment_mode.dart';
import '../../domain/enums/transaction_type.dart';
import 'database_helper.dart';

/// SQLite data source for [TransactionEntry].
///
/// Key design decisions:
///
/// 1. **No hardcoded mode strings in SQL.** Payment modes and transaction types
///    are stored and queried using `enum.name` (e.g. `PaymentMode.cash.name`
///    → `"cash"`). All string-to-SQL bindings are done through the enum API so
///    changes to the enum propagate automatically.
///
/// 2. **[isEdited] is not persisted yet.** The column does not exist in v2 of
///    the schema. The field is always set to `false` on read. A migration will
///    add the column in Phase 5.
///
/// 3. **[dateTime] is split on write / joined on read.** The entity exposes
///    a single [DateTime]; the database stores `date` (yyyy-MM-dd) and
///    `time` (HH:mm) as separate TEXT columns per the original schema.
class TransactionLocalDataSource {
  const TransactionLocalDataSource(this._db);

  final Database _db;

  static final _dateFmt = DateFormat('yyyy-MM-dd');
  static final _timeFmt = DateFormat('HH:mm');
  static final _joinFmt = DateFormat('yyyy-MM-dd HH:mm');

  // ─── Write ────────────────────────────────────────────────────────────────

  /// Inserts [entry] and returns the generated row id.
  Future<int> insertTransaction(TransactionEntry entry) async {
    final now = DateTime.now();
    return _db.insert(
      DatabaseHelper.tableTransactions,
      {
        DatabaseHelper.colTitle: entry.title,
        DatabaseHelper.colAmount: entry.amount,
        DatabaseHelper.colType: entry.type.name,           // enum.name — no magic strings
        DatabaseHelper.colPaymentMode: entry.paymentMode.name, // enum.name — no magic strings
        DatabaseHelper.colDate: _dateFmt.format(entry.dateTime),
        DatabaseHelper.colTime: _timeFmt.format(entry.dateTime),
        DatabaseHelper.colCreatedAt: now.toIso8601String(),
        DatabaseHelper.colUpdatedAt: now.toIso8601String(),
      },
    );
  }

  // ─── Read ─────────────────────────────────────────────────────────────────

  /// Returns the [limit] most-recent transactions ordered by insertion time.
  Future<List<TransactionEntry>> getRecentTransactions({
    required int limit,
  }) async {
    final rows = await _db.query(
      DatabaseHelper.tableTransactions,
      orderBy: '${DatabaseHelper.colCreatedAt} DESC',
      limit: limit,
    );
    return rows.map(_rowToEntity).toList();
  }

  // ─── Aggregate helpers ────────────────────────────────────────────────────

  /// SUM of `amount` for rows where `type` = [type] and `paymentMode` ∈ [modes].
  ///
  /// Uses parameterised IN clause built from `mode.name` values — no literals.
  /// Returns `0.0` when there are no matching rows.
  Future<double> sumByTypeAndModes({
    required TransactionType type,
    required List<PaymentMode> modes,
  }) async {
    final placeholders = modes.map((_) => '?').join(', ');
    final args = <Object>[
      type.name,
      ...modes.map((m) => m.name),
    ];

    final rows = await _db.rawQuery(
      '''
      SELECT COALESCE(SUM(${DatabaseHelper.colAmount}), 0) AS total
        FROM ${DatabaseHelper.tableTransactions}
       WHERE ${DatabaseHelper.colType} = ?
         AND ${DatabaseHelper.colPaymentMode} IN ($placeholders)
      ''',
      args,
    );

    return (rows.first['total'] as num? ?? 0).toDouble();
  }

  /// SUM of `amount` for rows where `type` = [type] and `date` = [dateString].
  ///
  /// [dateString] must be in `yyyy-MM-dd` format (supplied by [TransactionService]).
  /// Returns `0.0` when there are no matching rows.
  Future<double> sumTodayByType({
    required TransactionType type,
    required String dateString,
  }) async {
    final rows = await _db.rawQuery(
      '''
      SELECT COALESCE(SUM(${DatabaseHelper.colAmount}), 0) AS total
        FROM ${DatabaseHelper.tableTransactions}
       WHERE ${DatabaseHelper.colType} = ?
         AND ${DatabaseHelper.colDate}  = ?
      ''',
      [type.name, dateString],
    );

    return (rows.first['total'] as num? ?? 0).toDouble();
  }

  // ─── Mutation helpers ─────────────────────────────────────────────────────

  /// Updates all mutable fields of [entry] identified by [entry.id].
  ///
  /// `updatedAt` is always set to the current wall-clock time.
  /// Uses `enum.name` for type/mode — no hardcoded strings.
  Future<void> updateTransaction(TransactionEntry entry) async {
    final now = DateTime.now();
    await _db.update(
      DatabaseHelper.tableTransactions,
      {
        DatabaseHelper.colTitle: entry.title,
        DatabaseHelper.colAmount: entry.amount,
        DatabaseHelper.colType: entry.type.name,
        DatabaseHelper.colPaymentMode: entry.paymentMode.name,
        DatabaseHelper.colDate: _dateFmt.format(entry.dateTime),
        DatabaseHelper.colTime: _timeFmt.format(entry.dateTime),
        DatabaseHelper.colUpdatedAt: now.toIso8601String(),
      },
      where: '${DatabaseHelper.colId} = ?',
      whereArgs: [entry.id],
    );
  }

  /// Deletes the row with primary key [id]. No-op if the row doesn't exist.
  Future<void> deleteTransaction(int id) async {
    await _db.delete(
      DatabaseHelper.tableTransactions,
      where: '${DatabaseHelper.colId} = ?',
      whereArgs: [id],
    );
  }

  // ─── Phase 3 — Calendar & Ledger ──────────────────────────────────────────

  /// Returns all transactions where `date >= [from]` and `date < [until]`.
  ///
  /// Uses a half-open range on TEXT date columns (yyyy-MM-dd lexicographic
  /// ordering is identical to chronological ordering for ISO-8601 dates).
  Future<List<TransactionEntry>> getTransactionsByDateRange({
    required DateTime from,
    required DateTime until,
  }) async {
    final fromStr = _dateFmt.format(from);
    final untilStr = _dateFmt.format(until);

    final rows = await _db.rawQuery(
      '''
      SELECT *
        FROM ${DatabaseHelper.tableTransactions}
       WHERE ${DatabaseHelper.colDate} >= ?
         AND ${DatabaseHelper.colDate}  < ?
       ORDER BY ${DatabaseHelper.colDate} ASC,
                ${DatabaseHelper.colTime} ASC
      ''',
      [fromStr, untilStr],
    );
    return rows.map(_rowToEntity).toList();
  }

  /// Returns all transactions whose `date` column equals [date], ordered
  /// by `time` descending (newest first within the day).
  Future<List<TransactionEntry>> getTransactionsForDate(DateTime date) async {
    final dateStr = _dateFmt.format(date);

    final rows = await _db.rawQuery(
      '''
      SELECT *
        FROM ${DatabaseHelper.tableTransactions}
       WHERE ${DatabaseHelper.colDate} = ?
       ORDER BY ${DatabaseHelper.colTime} DESC
      ''',
      [dateStr],
    );
    return rows.map(_rowToEntity).toList();
  }

  /// Returns the SUM of amounts for rows where `date` is strictly before
  /// [before] and `type` matches [isIncome].
  ///
  /// TEXT date comparison is safe because yyyy-MM-dd sorts lexicographically.
  Future<double> sumBeforeDate({
    required DateTime before,
    required bool isIncome,
  }) async {
    final beforeStr = _dateFmt.format(before);
    final typeName = isIncome
        ? TransactionType.income.name
        : TransactionType.expense.name;

    final rows = await _db.rawQuery(
      '''
      SELECT COALESCE(SUM(${DatabaseHelper.colAmount}), 0) AS total
        FROM ${DatabaseHelper.tableTransactions}
       WHERE ${DatabaseHelper.colType} = ?
         AND ${DatabaseHelper.colDate}  < ?
      ''',
      [typeName, beforeStr],
    );
    return (rows.first['total'] as num? ?? 0).toDouble();
  }

  // ─── Phase 4 — Search, Exports & Settings ──────────────────────────────────

  /// Searches transactions matching title, payment mode, or date case-insensitively,
  /// ordered newest first.
  Future<List<TransactionEntry>> searchTransactions(String query) async {
    final likeQuery = '%$query%';
    final rows = await _db.rawQuery(
      '''
      SELECT *
        FROM ${DatabaseHelper.tableTransactions}
       WHERE ${DatabaseHelper.colTitle} LIKE ?
          OR ${DatabaseHelper.colPaymentMode} LIKE ?
          OR ${DatabaseHelper.colDate} LIKE ?
       ORDER BY ${DatabaseHelper.colDate} DESC,
                ${DatabaseHelper.colTime} DESC
      ''',
      [likeQuery, likeQuery, likeQuery],
    );
    return rows.map(_rowToEntity).toList();
  }

  /// Returns all transactions ordered newest first.
  Future<List<TransactionEntry>> getAllTransactions() async {
    final rows = await _db.rawQuery(
      '''
      SELECT *
        FROM ${DatabaseHelper.tableTransactions}
       ORDER BY ${DatabaseHelper.colDate} DESC,
                ${DatabaseHelper.colTime} DESC
      ''',
    );
    return rows.map(_rowToEntity).toList();
  }

  /// Deletes all transactions and app settings.
  Future<void> deleteAllData() async {
    await _db.transaction((txn) async {
      await txn.delete(DatabaseHelper.tableTransactions);
      await txn.delete(DatabaseHelper.tableAppSettings);
    });
  }

  /// Returns the total count of transactions in the database.
  Future<int> getTransactionCount() async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableTransactions}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─── Mapper ───────────────────────────────────────────────────────────────


  TransactionEntry _rowToEntity(Map<String, dynamic> row) {
    final dateStr = row[DatabaseHelper.colDate] as String;
    final timeStr = row[DatabaseHelper.colTime] as String;
    final dateTime = _joinFmt.parse('$dateStr $timeStr');

    return TransactionEntry(
      id: row[DatabaseHelper.colId] as int?,
      title: row[DatabaseHelper.colTitle] as String,
      amount: (row[DatabaseHelper.colAmount] as num).toDouble(),
      type: TransactionType.values.byName(row[DatabaseHelper.colType] as String),
      paymentMode: PaymentMode.values.byName(row[DatabaseHelper.colPaymentMode] as String),
      dateTime: dateTime,
      isEdited: false, // Phase 5 will add this column + migration
      createdAt: DateTime.parse(row[DatabaseHelper.colCreatedAt] as String),
      updatedAt: DateTime.parse(row[DatabaseHelper.colUpdatedAt] as String),
    );
  }
}

