import '../repositories/transaction_repository.dart';

/// Shared, stateless balance computation functions.
///
/// Architecture rule: all balance arithmetic lives here — not in the
/// repository, data source, or UI layer.
///
/// Two services use this calculator:
/// - [TransactionService] — dashboard running totals
/// - [LedgerService]      — per-day opening / closing balances
///
/// All methods accept a [TransactionRepository] to avoid constructor
/// coupling: each service passes its own repository instance.
abstract final class BalanceCalculator {
  /// Total balance at the **start** of [date] (i.e. after all transactions
  /// strictly before [date] have been applied to the initial seeds).
  ///
  /// Formula:
  ///   opening = initialCash + initialDigital
  ///           + Σ income(date < [date])
  ///           − Σ expense(date < [date])
  ///
  /// [date] is compared using `yyyy-MM-dd`; the time component is ignored.
  static Future<double> openingBalanceForDate(
    TransactionRepository repository, {
    required DateTime date,
    required double initialCash,
    required double initialDigital,
  }) async {
    final results = await Future.wait([
      repository.sumBeforeDate(
        before: date,
        isIncome: true,
      ),
      repository.sumBeforeDate(
        before: date,
        isIncome: false,
      ),
    ]);

    final incomeBefore = results[0];
    final expenseBefore = results[1];

    return initialCash + initialDigital + incomeBefore - expenseBefore;
  }
}
