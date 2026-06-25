import '../../domain/entities/timer_config.dart';
import '../../domain/repositories/timer_repository.dart';
import '../datasources/timer_local_datasource.dart';

/// TimerRepository somut uygulaması.
class TimerRepositoryImpl implements TimerRepository {
  final TimerLocalDatasource _datasource;

  TimerRepositoryImpl(this._datasource);

  @override
  Future<TimerConfig?> getLastConfig() async {
    return _datasource.getLastConfig();
  }

  @override
  Future<void> saveConfig(TimerConfig config) async {
    await _datasource.saveConfig(config);
  }

  @override
  Future<List<TimerConfig>> getSavedConfigs() async {
    return _datasource.getAllConfigs();
  }

  @override
  Future<void> deleteConfig(int index) async {
    await _datasource.deleteConfig(index);
  }
}
