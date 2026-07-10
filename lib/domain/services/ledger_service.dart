import '../entities/daily_ledger.dart';
import '../entities/daily_summary.dart';
import '../entities/transaction_entry.dart';
import '../enums/transaction_type.dart';
import '../repositories/transaction_repository.dart';
import 'balance_calculator.dart';

/// Service that owns all Calendar and Daily Ledger business logic.
///
/// Kept separate from [TransactionService] (which handles Dashboard logic)
/// so each service has a single responsibility.
///
/// Architecture rules:
/// - No balance arithmetic lives here — it delegates to [BalanceCalculator].
/// - No SQL lives here — it delegates to [TransactionRepository].
/// - Initial seed balances are always passed in; never read from settings here.
class LedgerService {
  const LedgerService(this._repository);

  final TransactionRepository _repository;

  // ─── Calendar Month View ─────────────────────────────────────────────────

  /// Returns a map of `yyyy-MM-dd` → [DailySummary] for every day that has
  /// at least one transaction in the given [year] / [month].
  ///
  /// Days with no transactions are absent from the map — callers should treat
  /// a missing key as a zero-value day.
  ///
  /// Uses a half-open date range: >= first day of month AND < first day of
  /// next month. This avoids BETWEEN ambiguity with TEXT date comparisons.
  Future<Map<String, DailySummary>> getMonthSummaries(
    int year,
    int month,
  ) async {
    final firstDay = DateTime(year, month, 1);
    final firstDayNextMonth = DateTime(year, month + 1, 1);

    final entries = await _repository.getTransactionsByDateRange(
      from: firstDay,
      until: firstDayNextMonth,
    );

    // Group entries by yyyy-MM-dd and aggregate.
    final Map<String, _DayAccumulator> accumulators = {};

    for (final entry in entries) {
      final key = _dateKey(entry.dateTime);
      final acc = accumulators.putIfAbsent(key, () => _DayAccumulator());
      if (entry.type == TransactionType.income) {
        acc.income += entry.amount;
      } else {
        acc.expense += entry.amount;
      }
      acc.count++;
    }

    return accumulators.map(
      (key, acc) => MapEntry(
        key,
        DailySummary(
          date: DateTime.parse(key),
          totalIncome: acc.income,
          totalExpense: acc.expense,
          transactionCount: acc.count,
        ),
      ),
    );
  }

  /// Returns the aggregate income and expense totals for the given month.
  ///
  /// These values are computed by summing the day-level summaries so there
  /// is no additional database query — pass the result of [getMonthSummaries]
  /// directly to avoid duplicate SQL calls.
  static ({double income, double expense}) monthTotalsFromSummaries(
    Map<String, DailySummary> summaries,
  ) {
    double income = 0;
    double expense = 0;
    for (final s in summaries.values) {
      income += s.totalIncome;
      expense += s.totalExpense;
    }
    return (income: income, expense: expense);
  }

  // ─── Daily Ledger ─────────────────────────────────────────────────────────

  /// Returns the complete [DailyLedger] for [date].
  ///
  /// Opening and closing balances are calculated via [BalanceCalculator]
  /// and are never stored in the database.
  ///
  /// [initialCash] and [initialDigital] come from [AppSettings] (passed by
  /// the provider — this service never reads settings directly).
  Future<DailyLedger> getDailyLedger(
    DateTime date, {
    required double initialCash,
    required double initialDigital,
  }) async {
    // Run opening balance and transactions in parallel.
    final results = await Future.wait([
      BalanceCalculator.openingBalanceForDate(
        _repository,
        date: date,
        initialCash: initialCash,
        initialDigital: initialDigital,
      ),
      _repository.getTransactionsForDate(date),
    ]);

    final openingBalance = results[0] as double;
    final transactions = results[1] as List<TransactionEntry>;

    double income = 0;
    double expense = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    return DailyLedger(
      date: date,
      openingBalance: openingBalance,
      transactions: transactions,
      totalIncome: income,
      totalExpense: expense,
      closingBalance: openingBalance + income - expense,
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  static String _dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}

/// Mutable accumulator used during month aggregation.
class _DayAccumulator {
  double income = 0;
  double expense = 0;
  int count = 0;
}
