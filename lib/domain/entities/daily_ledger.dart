import 'transaction_entry.dart';

/// Full ledger for a single day, returned by [LedgerService.getDailyLedger].
///
/// Design rules (from Architecture.md):
///
/// - [openingBalance] and [closingBalance] are **never stored**.
///   They are calculated at query time by [BalanceCalculator].
///   If any historical transaction is edited or deleted, invalidating
///   the provider causes automatic recalculation.
///
/// - [transactions] is ordered newest-first (by time within the day).
///
/// Balance formulas:
///
///   openingBalance = initialCash + initialDigital
///                  + Σ income(date < this.date)
///                  − Σ expense(date < this.date)
///
///   closingBalance = openingBalance + totalIncome − totalExpense
class DailyLedger {
  const DailyLedger({
    required this.date,
    required this.openingBalance,
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.closingBalance,
  });

  /// The calendar date this ledger represents.
  final DateTime date;

  /// Closing balance of the previous day (calculated, never stored).
  final double openingBalance;

  /// All transactions for [date], newest first.
  final List<TransactionEntry> transactions;

  /// Sum of all income transactions on [date].
  final double totalIncome;

  /// Sum of all expense transactions on [date].
  final double totalExpense;

  /// Net of the day added to [openingBalance] (calculated, never stored).
  final double closingBalance;

  /// Net change for the day (income − expense).
  double get netForDay => totalIncome - totalExpense;

  /// Number of transactions recorded on [date].
  int get transactionCount => transactions.length;

  bool get hasTransactions => transactions.isNotEmpty;

  @override
  String toString() => 'DailyLedger('
      'date: $date, '
      'opening: $openingBalance, '
      'income: $totalIncome, '
      'expense: $totalExpense, '
      'closing: $closingBalance, '
      'count: $transactionCount)';
}
