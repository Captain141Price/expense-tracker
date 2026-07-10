/// Per-day aggregated income and expense totals used to populate
/// the calendar grid cells.
///
/// Produced by [LedgerService.getMonthSummaries].
/// Never stored — always derived from the transactions table.
class DailySummary {
  const DailySummary({
    required this.date,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactionCount,
  });

  final DateTime date;

  /// Sum of all income amounts recorded on [date].
  final double totalIncome;

  /// Sum of all expense amounts recorded on [date].
  final double totalExpense;

  /// Total number of transactions recorded on [date].
  final int transactionCount;

  bool get hasTransactions => transactionCount > 0;

  @override
  String toString() => 'DailySummary('
      'date: $date, '
      'income: $totalIncome, '
      'expense: $totalExpense, '
      'count: $transactionCount)';
}
