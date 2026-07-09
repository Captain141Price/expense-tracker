import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../entities/dashboard_summary.dart';
import '../entities/transaction_entry.dart';
import '../enums/payment_mode.dart';
import '../enums/transaction_type.dart';
import '../repositories/transaction_repository.dart';

/// Service layer that owns **all** balance and summary calculations.
///
/// Sits between Riverpod providers and [TransactionRepository].
///
/// Architecture rule: no balance arithmetic exists in the repository,
/// the data source, or the UI layer — it all lives here.
class TransactionService {
  const TransactionService(this._repository);

  final TransactionRepository _repository;

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  // ─── Balance Calculations ────────────────────────────────────────────────

  /// Cash Balance = [initialCash] + Σ cash income − Σ cash expense.
  Future<double> getCashBalance(double initialCash) async {
    final income = await _repository.sumByTypeAndModes(
      type: TransactionType.income,
      modes: [PaymentMode.cash],
    );
    final expense = await _repository.sumByTypeAndModes(
      type: TransactionType.expense,
      modes: [PaymentMode.cash],
    );
    return initialCash + income - expense;
  }

  /// Digital Balance = [initialDigital] + Σ (UPI + Card) income − Σ (UPI + Card) expense.
  Future<double> getDigitalBalance(double initialDigital) async {
    final income = await _repository.sumByTypeAndModes(
      type: TransactionType.income,
      modes: [PaymentMode.upi, PaymentMode.card],
    );
    final expense = await _repository.sumByTypeAndModes(
      type: TransactionType.expense,
      modes: [PaymentMode.upi, PaymentMode.card],
    );
    return initialDigital + income - expense;
  }

  // ─── Dashboard Summary ───────────────────────────────────────────────────

  /// Aggregates all data needed by the Dashboard into a [DashboardSummary].
  ///
  /// All four queries run in parallel via [Future.wait] for efficiency.
  Future<DashboardSummary> getDashboardSummary({
    required double initialCash,
    required double initialDigital,
  }) async {
    final today = _dateFormat.format(DateTime.now());

    final results = await Future.wait([
      getCashBalance(initialCash),
      getDigitalBalance(initialDigital),
      _repository.sumTodayByType(
        type: TransactionType.income,
        dateString: today,
      ),
      _repository.sumTodayByType(
        type: TransactionType.expense,
        dateString: today,
      ),
    ]);

    return DashboardSummary(
      cashBalance: results[0],
      digitalBalance: results[1],
      todayIncome: results[2],
      todayExpense: results[3],
    );
  }

  // ─── Transactions ────────────────────────────────────────────────────────

  /// Inserts a new transaction and returns its generated id.
  Future<int> addTransaction(TransactionEntry entry) {
    return _repository.insertTransaction(entry);
  }

  /// Returns the [AppConstants.recentTransactionsLimit] most-recent entries.
  Future<List<TransactionEntry>> getRecentTransactions() {
    return _repository.getRecentTransactions(
      limit: AppConstants.recentTransactionsLimit,
    );
  }

  /// Updates [entry] in the database.
  ///
  /// [entry.id] must be non-null. Sets `isEdited = true` via the entity's
  /// [copyWith] if not already set — the entity itself carries the flag.
  Future<void> updateTransaction(TransactionEntry entry) {
    return _repository.updateTransaction(entry);
  }

  /// Deletes the transaction with [id] from the database.
  Future<void> deleteTransaction(int id) {
    return _repository.deleteTransaction(id);
  }
}
