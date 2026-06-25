import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource _datasource;
  SettingsRepositoryImpl(this._datasource);

  @override
  Future<AppSettings> getSettings() => _datasource.getSettings();

  @override
  Future<void> updateSettings(AppSettings settings) =>
      _datasource.updateSettings(settings);
}
