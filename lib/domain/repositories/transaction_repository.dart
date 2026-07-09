import '../entities/transaction_entry.dart';
import '../enums/payment_mode.dart';
import '../enums/transaction_type.dart';

/// Abstract interface for all transaction persistence operations.
///
/// Balance calculations are deliberately absent from this interface —
/// they live in [TransactionService]. This repository exposes only the
/// raw aggregation primitives that the service composes.
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
}
