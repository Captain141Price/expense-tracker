import '../../domain/entities/transaction_entry.dart';
import '../../domain/enums/payment_mode.dart';
import '../../domain/enums/transaction_type.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../local/transaction_local_data_source.dart';

/// Concrete implementation of [TransactionRepository] backed by SQLite.
///
/// Delegates all work to [TransactionLocalDataSource], keeping this class thin.
class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._dataSource);

  final TransactionLocalDataSource _dataSource;

  @override
  Future<int> insertTransaction(TransactionEntry entry) =>
      _dataSource.insertTransaction(entry);

  @override
  Future<List<TransactionEntry>> getRecentTransactions({required int limit}) =>
      _dataSource.getRecentTransactions(limit: limit);

  @override
  Future<double> sumByTypeAndModes({
    required TransactionType type,
    required List<PaymentMode> modes,
  }) =>
      _dataSource.sumByTypeAndModes(type: type, modes: modes);

  @override
  Future<double> sumTodayByType({
    required TransactionType type,
    required String dateString,
  }) =>
      _dataSource.sumTodayByType(type: type, dateString: dateString);

  @override
  Future<void> updateTransaction(TransactionEntry entry) =>
      _dataSource.updateTransaction(entry);

  @override
  Future<void> deleteTransaction(int id) =>
      _dataSource.deleteTransaction(id);

  // ─── Phase 3 — Calendar & Ledger ─────────────────────────────────────────

  @override
  Future<List<TransactionEntry>> getTransactionsByDateRange({
    required DateTime from,
    required DateTime until,
  }) =>
      _dataSource.getTransactionsByDateRange(from: from, until: until);

  @override
  Future<List<TransactionEntry>> getTransactionsForDate(DateTime date) =>
      _dataSource.getTransactionsForDate(date);

  @override
  Future<double> sumBeforeDate({
    required DateTime before,
    required bool isIncome,
  }) =>
      _dataSource.sumBeforeDate(before: before, isIncome: isIncome);

  // ─── Phase 4 — Search, Exports & Settings ────────────────────────────────

  @override
  Future<List<TransactionEntry>> searchTransactions(String query) =>
      _dataSource.searchTransactions(query);

  @override
  Future<List<TransactionEntry>> getAllTransactions() =>
      _dataSource.getAllTransactions();

  @override
  Future<void> deleteAllData() =>
      _dataSource.deleteAllData();

  @override
  Future<int> getTransactionCount() =>
      _dataSource.getTransactionCount();
}

