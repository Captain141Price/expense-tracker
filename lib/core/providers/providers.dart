import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/local/app_settings_local_data_source.dart';
import '../../data/local/database_helper.dart';
import '../../data/repositories/app_settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/app_settings_repository.dart';

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

