import 'package:get_it/get_it.dart';

import '../../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../../features/settings/domain/repositories/settings_repository.dart';
import '../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../features/settings/presentation/bloc/settings_event.dart';

/// Settings feature bağımlılıklarını kaydeder.
abstract final class SettingsModule {
  static void register(GetIt sl) {
    sl.registerLazySingleton<SettingsLocalDatasource>(
      () => SettingsLocalDatasource(),
    );
    sl.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl()),
    );
    // SettingsBloc: app genelinde tek instance — tüm sayfalarda aynı ayarlar.
    sl.registerLazySingleton<SettingsBloc>(
      () => SettingsBloc(repository: sl())..add(const SettingsLoadRequested()),
    );
  }
}
