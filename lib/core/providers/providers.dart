import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../data/local/app_settings_local_data_source.dart';
import '../../data/local/database_helper.dart';
import '../../data/local/transaction_local_data_source.dart';
import '../../data/repositories/app_settings_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/daily_ledger.dart';
import '../../domain/entities/daily_summary.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/database_health_info.dart';
import '../../domain/entities/transaction_entry.dart';
import '../../domain/enums/payment_mode.dart';
import '../../domain/enums/transaction_type.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/services/ledger_service.dart';
import '../../domain/services/transaction_service.dart';


// ─── Session State ────────────────────────────────────────────────────────────

/// Remembers the user's last-used [PaymentMode] for the current app session.
///
/// Not persisted to the database — resets to [PaymentMode.cash] on app restart.
/// Updated by [AddTransactionSheet] after every successful save.
final lastPaymentModeProvider = StateProvider<PaymentMode>(
  (ref) => PaymentMode.cash,
);

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

/// Provides the [LedgerService] that owns Calendar and Daily Ledger logic.
///
/// Kept separate from [transactionServiceProvider] (Dashboard logic) so each
/// service has a single responsibility.
final ledgerServiceProvider = FutureProvider<LedgerService>((ref) async {
  final repository = await ref.watch(transactionRepositoryProvider.future);
  return LedgerService(repository);
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

/// Home screen filter for transaction type (All, Income, Expense).
final homeFilterTypeProvider = StateProvider<String>((ref) => 'All');

/// Home screen filter for payment mode (All, Cash, UPI, Card).
final homeFilterModeProvider = StateProvider<String>((ref) => 'All');

/// Provides the filtered list of most-recent transactions based on Home screen chips.
///
/// Automatically rebuilds when filters are changed.
final recentTransactionsProvider =
    FutureProvider<List<TransactionEntry>>((ref) async {
  final service = await ref.watch(transactionServiceProvider.future);
  final txs = await service.getRecentTransactions();

  final typeFilter = ref.watch(homeFilterTypeProvider);
  final modeFilter = ref.watch(homeFilterModeProvider);

  return txs.where((t) {
    final matchesType = typeFilter == 'All' ||
        (typeFilter == 'Income' && t.type == TransactionType.income) ||
        (typeFilter == 'Expense' && t.type == TransactionType.expense);

    final matchesMode = modeFilter == 'All' ||
        (modeFilter == 'Cash' && t.paymentMode == PaymentMode.cash) ||
        (modeFilter == 'UPI' && t.paymentMode == PaymentMode.upi) ||
        (modeFilter == 'Card' && t.paymentMode == PaymentMode.card);

    return matchesType && matchesMode;
  }).toList();
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
      // Invalidate calendar so the day cell updates immediately.
      ref.invalidate(monthSummariesProvider);
      // Invalidate any cached ledger for the affected day.
      ref.invalidate(dailyLedgerProvider);
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
      ref.invalidate(monthSummariesProvider);
      ref.invalidate(dailyLedgerProvider);
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
      ref.invalidate(monthSummariesProvider);
      ref.invalidate(dailyLedgerProvider);
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

// ─── Phase 3 — Calendar & Ledger ──────────────────────────────────────────

/// Tracks the currently displayed calendar month.
///
/// Initialised to the current month. The calendar header arrows call
/// `ref.read(calendarMonthProvider.notifier).state = newDate`.
/// Not persisted — resets to the current month on app restart.
final calendarMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

/// Tracks the currently selected/highlighted date on the Calendar.
///
/// Set to null by default, or updated when user jumps to a date or taps today.
final calendarSelectedDateProvider = StateProvider<DateTime?>((ref) => null);


/// Provides a map of `yyyy-MM-dd` → [DailySummary] for the currently
/// displayed calendar month.
///
/// Automatically rebuilds when [calendarMonthProvider] changes (month
/// navigation) or when any transaction mutation invalidates this provider.
/// Days with no transactions are absent from the map.
final monthSummariesProvider =
    FutureProvider<Map<String, DailySummary>>((ref) async {
  final service = await ref.watch(ledgerServiceProvider.future);
  final month = ref.watch(calendarMonthProvider);
  return service.getMonthSummaries(month.year, month.month);
});

/// Provides the [DailyLedger] for a specific [date].
///
/// This is a family provider keyed by a `DateTime` (normalised to
/// midnight — only the date part matters). Each date has its own
/// independent cache. Invalidated by any transaction mutation so that
/// balance recalculation is always correct.
///
/// Usage:
///   `ref.watch(dailyLedgerProvider(date))`
final dailyLedgerProvider =
    FutureProvider.family<DailyLedger, DateTime>((ref, date) async {
  final service = await ref.watch(ledgerServiceProvider.future);
  final settings = await ref.watch(appSettingsProvider.future);
  final normalised = DateTime(date.year, date.month, date.day);
  return service.getDailyLedger(
    normalised,
    initialCash: settings?.initialCash ?? 0.0,
    initialDigital: settings?.initialDigital ?? 0.0,
  );
});

// ─── Phase 4 — Search & Settings ──────────────────────────────────────────

/// Tracks the active search text query.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provides search results from SQLite matching the query.
final searchResultsProvider =
    FutureProvider<List<TransactionEntry>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  final repository = await ref.watch(transactionRepositoryProvider.future);
  return repository.searchTransactions(query.trim());
});

/// Provides database health metrics and diagnostics information.
final databaseStatsProvider = FutureProvider<DatabaseHealthInfo>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final repository = await ref.watch(transactionRepositoryProvider.future);

  final path = db.path;
  final file = File(path);
  final sizeBytes = await file.exists() ? await file.length() : 0;

  final totalTransactions = await repository.getTransactionCount();

  final versionResult = await db.rawQuery('SELECT sqlite_version()');
  final sqliteVersion = versionResult.first.values.first as String;

  final databasesDir = p.dirname(path);
  final metaFile = File(p.join(databasesDir, 'backup_metadata.txt'));
  String lastBackup = 'Never';
  if (await metaFile.exists()) {
    lastBackup = await metaFile.readAsString();
  }

  return DatabaseHealthInfo(
    sizeBytes: sizeBytes,
    totalTransactions: totalTransactions,
    lastBackup: lastBackup,
    sqliteVersion: sqliteVersion,
    storageLocation: path,
  );
});

