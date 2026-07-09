/// Encapsulates all balance and today-summary data required by the Dashboard.
///
/// All values except [cashBalance] and [digitalBalance] are derived — they
/// are never stored as separate columns in the database. This enforces the
/// architecture rule: *never duplicate balance data unnecessarily.*
///
/// Created by [TransactionService.getDashboardSummary] which aggregates all
/// required SQL queries into a single object.
class DashboardSummary {
  const DashboardSummary({
    required this.cashBalance,
    required this.digitalBalance,
    required this.todayIncome,
    required this.todayExpense,
  });

  /// Running cash balance: `initialCash` + Σ cash income − Σ cash expense.
  final double cashBalance;

  /// Running digital balance: `initialDigital` + Σ (UPI + Card) income − Σ (UPI + Card) expense.
  final double digitalBalance;

  /// Sum of all income transactions for today (any payment mode).
  final double todayIncome;

  /// Sum of all expense transactions for today (any payment mode).
  final double todayExpense;

  // ─── Derived ─────────────────────────────────────────────────────────────

  /// Total Balance = Cash Balance + Digital Balance. Never stored.
  double get totalBalance => cashBalance + digitalBalance;

  /// Today's Net = Today's Income − Today's Expense. Never stored.
  double get todayNet => todayIncome - todayExpense;

  @override
  String toString() => 'DashboardSummary('
      'cashBalance: $cashBalance, '
      'digitalBalance: $digitalBalance, '
      'todayIncome: $todayIncome, '
      'todayExpense: $todayExpense, '
      'totalBalance: $totalBalance, '
      'todayNet: $todayNet)';
}
