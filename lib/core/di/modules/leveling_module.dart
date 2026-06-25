import 'package:get_it/get_it.dart';

import '../../../features/leveling/data/datasources/leveling_remote_datasource.dart';
import '../../../features/leveling/data/repositories/leveling_repository_impl.dart';
import '../../../features/leveling/domain/repositories/leveling_repository.dart';
import '../../../features/leveling/domain/usecases/get_user_level.dart';
import '../../../features/leveling/domain/usecases/stream_xp_updates.dart';
import '../../../features/leveling/presentation/bloc/level_bloc.dart';

/// Leveling (XP & Seviye) feature bağımlılıklarını kaydeder.
abstract final class LevelingModule {
  static void register(GetIt sl) {
    sl.registerLazySingleton<LevelingRemoteDataSource>(
      () => LevelingRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<LevelingRepository>(
      () => LevelingRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<GetUserLevel>(() => GetUserLevel(sl()));
    sl.registerLazySingleton<StreamXpUpdates>(() => StreamXpUpdates(sl()));
    // LevelBloc: registerFactory → her sayfada taze instance oluşturulur.
    sl.registerFactory<LevelBloc>(
      () => LevelBloc(
        getUserLevel: sl(),
        streamXpUpdates: sl(),
        repository: sl(),
      ),
    );
  }
}
