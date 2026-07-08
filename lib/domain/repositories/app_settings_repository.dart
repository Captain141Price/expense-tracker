import '../entities/app_settings.dart';

/// Contract for reading and writing application settings.
///
/// The data layer provides the concrete implementation.
/// Business logic (use-cases, providers) depends only on this interface.
abstract interface class AppSettingsRepository {
  /// Returns the stored [AppSettings], or `null` on a fresh install
  /// before setup has been completed.
  Future<AppSettings?> getSettings();

  /// Creates the initial settings row using the balances the user entered
  /// on the Initial Balance screen. Sets [isFirstLaunch] to `false`.
  Future<void> createSettings({
    required double initialCash,
    required double initialDigital,
  });

  /// Marks the first-launch flow as complete.
  ///
  /// Called after the user finishes the Initial Balance screen.
  Future<void> completeFirstLaunch();
}
