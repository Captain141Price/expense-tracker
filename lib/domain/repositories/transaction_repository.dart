import '../entities/transaction_entry.dart';
import '../enums/payment_mode.dart';
import '../enums/transaction_type.dart';

/// Abstract interface for all transaction persistence operations.
///
/// Balance calculations are deliberately absent from this interface —
/// they live in [TransactionService] / [LedgerService]. This repository
/// exposes only the raw aggregation primitives that the services compose.
abstract interface class TransactionRepository {
  /// Inserts [entry] into the database and returns the generated row id.
  Future<int> insertTransaction(TransactionEntry entry);

  /// Returns the [limit] most-recent transactions, ordered newest first.
  Future<List<TransactionEntry>> getRecentTransactions({required int limit});

  /// Returns the SUM of [amount] for all rows where [type] matches and
  /// [paymentMode] is contained in [modes].
  ///
  /// Returns `0.0` when no matching rows exist.
  Future<double> sumByTypeAndModes({
    required TransactionType type,
    required List<PaymentMode> modes,
  });

  /// Returns the SUM of [amount] for all rows where [type] matches and
  /// the stored `date` column equals [dateString].
  ///
  /// [dateString] must be in `yyyy-MM-dd` format.
  /// Returns `0.0` when no matching rows exist.
  Future<double> sumTodayByType({
    required TransactionType type,
    required String dateString,
  });

  /// Updates [entry] in the database.
  ///
  /// [entry.id] must be non-null. All mutable fields are overwritten;
  /// `updatedAt` is set to the current timestamp by the data source.
  Future<void> updateTransaction(TransactionEntry entry);

  /// Deletes the row with [id] from the database.
  ///
  /// No-op if the row does not exist.
  Future<void> deleteTransaction(int id);

  // ─── Phase 3 — Calendar & Ledger ─────────────────────────────────────────

  /// Returns all transactions where `date >= [from]` and `date < [until]`.
  ///
  /// Uses a **half-open** range to avoid BETWEEN ambiguity with TEXT columns.
  /// [from] and [until] are compared on the `yyyy-MM-dd` part only.
  Future<List<TransactionEntry>> getTransactionsByDateRange({
    required DateTime from,
    required DateTime until,
  });

  /// Returns all transactions whose `date` column matches [date], ordered
  /// by `time` descending (newest first within the day).
  Future<List<TransactionEntry>> getTransactionsForDate(DateTime date);

  /// Returns the SUM of all income (or expense) amounts for rows where
  /// date is strictly **before** [before] (i.e. `date < [before]`).
  ///
  /// Used by [BalanceCalculator] to compute opening balances.
  /// [isIncome] selects whether to sum `type = 'income'` or `type = 'expense'`.
  Future<double> sumBeforeDate({
    required DateTime before,
    required bool isIncome,
  });

  // ─── Phase 4 — Search, Exports & Settings ────────────────────────────────

  /// Searches transactions matching title, payment mode, or date case-insensitively,
  /// ordered newest first.
  Future<List<TransactionEntry>> searchTransactions(String query);

  /// Returns all transactions ordered chronologically (newest first).
  ///
  /// Used for CSV and PDF exports.
  Future<List<TransactionEntry>> getAllTransactions();

  /// Deletes all transactions and resets application settings.
  Future<void> deleteAllData();

  /// Returns the total count of transactions in the database.
  Future<int> getTransactionCount();
}
