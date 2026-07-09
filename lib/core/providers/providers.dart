import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/local/app_settings_local_data_source.dart';
import '../../data/local/database_helper.dart';
import '../../data/local/transaction_local_data_source.dart';
import '../../data/repositories/app_settings_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/transaction_entry.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/services/transaction_service.dart';

// ─── Database ────────────────────────────────────────────────────────────────

/// Provides an initialised [Database] instance to the application.
///
/// Consuming widgets should watch this provider inside a [ProviderScope].
/// The database is initialised once and reused for the application lifetime.
final databaseProvider = FutureProvider<Database>((ref) async {
  return DatabaseHelper.instance.database;
});

// ─── App Settings ─────────────────────────────────────────────────────────────

/// Provides the [AppSettingsRepository] backed by SQLite.
final appSettingsRepositoryProvider =
    FutureProvider<AppSettingsRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final dataSource = AppSettingsLocalDataSource(db);
  return AppSettingsRepositoryImpl(dataSource);
});

/// Provides the current [AppSettings] row, or `null` on a fresh install.
///
/// Returns `null` when the user has not yet completed the first-launch flow.
final appSettingsProvider = FutureProvider<AppSettings?>((ref) async {
  final repository = await ref.watch(appSettingsRepositoryProvider.future);
  return repository.getSettings();
});

// ─── Initial Balance (onboarding) ────────────────────────────────────────────

/// Handles saving the initial balances entered on [InitialBalanceScreen].
///
/// Call [saveBalances] with the validated cash and digital amounts.
/// On success the provider transitions to [AsyncData(null)] and the caller
/// can navigate to Home. On failure it transitions to [AsyncError].
class SaveInitialBalanceNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Persists [initialCash] and [initialDigital] to the [app_settings] table
  /// and invalidates [appSettingsProvider] so subsequent reads reflect the
  /// saved values.
  Future<void> saveBalances({
    required double initialCash,
    required double initialDigital,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository =
          await ref.read(appSettingsRepositoryProvider.future);
      await repository.createSettings(
        initialCash: initialCash,
        initialDigital: initialDigital,
      );
      ref.invalidate(appSettingsProvider);
    });
  }
}

/// Provider for [SaveInitialBalanceNotifier].
final saveInitialBalanceProvider =
    AsyncNotifierProvider<SaveInitialBalanceNotifier, void>(
  SaveInitialBalanceNotifier.new,
);

// ─── Transactions ─────────────────────────────────────────────────────────────

/// Provides the [TransactionRepository] backed by SQLite.
final transactionRepositoryProvider =
    FutureProvider<TransactionRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final dataSource = TransactionLocalDataSource(db);
  return TransactionRepositoryImpl(dataSource);
});

/// Provides the [TransactionService] that owns all balance calculations.
///
/// This is the only way consumers should access transaction logic — not the
/// repository directly.
final transactionServiceProvider =
    FutureProvider<TransactionService>((ref) async {
  final repository = await ref.watch(transactionRepositoryProvider.future);
  return TransactionService(repository);
});

// ─── Dashboard ────────────────────────────────────────────────────────────────

/// Provides a [DashboardSummary] (all balances + today's figures).
///
/// Invalidated by [AddTransactionNotifier.addTransaction] after each save,
/// which causes [HomeScreen] to automatically rebuild with fresh data.
final dashboardSummaryProvider =
    FutureProvider<DashboardSummary>((ref) async {
  final service = await ref.watch(transactionServiceProvider.future);
  final settings = await ref.watch(appSettingsProvider.future);
  return service.getDashboardSummary(
    initialCash: settings?.initialCash ?? 0.0,
    initialDigital: settings?.initialDigital ?? 0.0,
  );
});

/// Provides the most-recent [AppConstants.recentTransactionsLimit] transactions.
///
/// Invalidated by [AddTransactionNotifier.addTransaction] after each save.
final recentTransactionsProvider =
    FutureProvider<List<TransactionEntry>>((ref) async {
  final service = await ref.watch(transactionServiceProvider.future);
  return service.getRecentTransactions();
});

// ─── Add Transaction ─────────────────────────────────────────────────────────

/// Handles inserting a new transaction and refreshing all dashboard providers.
///
/// Calling [addTransaction] inserts the entry into SQLite then invalidates
/// [dashboardSummaryProvider] and [recentTransactionsProvider] so the
/// Dashboard rebuilds without requiring a restart.
class AddTransactionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Persists [entry] and triggers a live Dashboard refresh.
  ///
  /// Throws on failure so the caller (the bottom sheet) can show an error
  /// message without the exception being silently swallowed.
  Future<void> addTransaction(TransactionEntry entry) async {
    state = const AsyncLoading();
    try {
      final service = await ref.read(transactionServiceProvider.future);
      await service.addTransaction(entry);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(recentTransactionsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// Provider for [AddTransactionNotifier].
final addTransactionProvider =
    AsyncNotifierProvider<AddTransactionNotifier, void>(
  AddTransactionNotifier.new,
);

// ─── Edit Transaction ─────────────────────────────────────────────────────────

/// Handles updating an existing transaction and refreshing all dashboard providers.
///
/// Calling [updateTransaction] performs an UPDATE in SQLite, then invalidates
/// [dashboardSummaryProvider] and [recentTransactionsProvider] so the
/// Dashboard rebuilds without requiring a restart.
class EditTransactionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Updates [entry] in SQLite and triggers a live Dashboard refresh.
  ///
  /// [entry.id] must be non-null.
  /// Throws on failure so the caller (the bottom sheet) can show an error.
  Future<void> updateTransaction(TransactionEntry entry) async {
    state = const AsyncLoading();
    try {
      final service = await ref.read(transactionServiceProvider.future);
      await service.updateTransaction(entry);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(recentTransactionsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// Provider for [EditTransactionNotifier].
final editTransactionProvider =
    AsyncNotifierProvider<EditTransactionNotifier, void>(
  EditTransactionNotifier.new,
);

// ─── Delete Transaction ───────────────────────────────────────────────────────

/// Handles deleting a transaction and refreshing all dashboard providers.
///
/// Calling [deleteTransaction] performs a DELETE in SQLite, then invalidates
/// [dashboardSummaryProvider] and [recentTransactionsProvider] so the
/// Dashboard rebuilds without requiring a restart.
class DeleteTransactionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Deletes the transaction with [id] from SQLite and refreshes the Dashboard.
  ///
  /// Throws on failure so the caller can surface a user-facing error.
  Future<void> deleteTransaction(int id) async {
    state = const AsyncLoading();
    try {
      final service = await ref.read(transactionServiceProvider.future);
      await service.deleteTransaction(id);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(recentTransactionsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// Provider for [DeleteTransactionNotifier].
final deleteTransactionProvider =
    AsyncNotifierProvider<DeleteTransactionNotifier, void>(
  DeleteTransactionNotifier.new,
);
