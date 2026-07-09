/// Shared application-level constants for Expense Notebook.
///
/// All magic numbers that are used in more than one place should be
/// defined here to keep the codebase easy to change in the future.
abstract final class AppConstants {
  /// Maximum number of recent transactions displayed on the Dashboard.
  ///
  /// Used by [TransactionService.getRecentTransactions] and respected by the
  /// repository query — change here to propagate everywhere automatically.
  static const int recentTransactionsLimit = 10;
}
