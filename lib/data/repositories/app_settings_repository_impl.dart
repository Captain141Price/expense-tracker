import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../local/app_settings_local_data_source.dart';

/// Concrete implementation of [AppSettingsRepository] backed by SQLite.
class AppSettingsRepositoryImpl implements AppSettingsRepository {
  const AppSettingsRepositoryImpl(this._dataSource);

  final AppSettingsLocalDataSource _dataSource;

  @override
  Future<AppSettings?> getSettings() => _dataSource.fetchSettings();

  @override
  Future<void> createSettings({
    required double initialCash,
    required double initialDigital,
  }) =>
      _dataSource.insertSettings(
        initialCash: initialCash,
        initialDigital: initialDigital,
      );

  @override
  Future<void> completeFirstLaunch() => _dataSource.markFirstLaunchComplete();
}
