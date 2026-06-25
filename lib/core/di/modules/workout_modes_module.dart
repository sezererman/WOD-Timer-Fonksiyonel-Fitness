import 'package:get_it/get_it.dart';

import '../../../features/workout_modes/data/datasources/workout_mode_local_datasource.dart';
import '../../../features/workout_modes/data/repositories/workout_mode_repository_impl.dart';
import '../../../features/workout_modes/domain/repositories/workout_mode_repository.dart';
import '../../../features/workout_modes/presentation/bloc/workout_mode_bloc.dart';
import '../../../features/workout_modes/presentation/bloc/workout_mode_event.dart';

/// WorkoutModes ve Timer bağlı mod listesi bağımlılıklarını kaydeder.
abstract final class WorkoutModesModule {
  static void register(GetIt sl) {
    sl.registerLazySingleton<WorkoutModeLocalDatasource>(
      () => WorkoutModeLocalDatasource(sl()),
    );
    sl.registerLazySingleton<WorkoutModeRepository>(
      () => WorkoutModeRepositoryImpl(sl()),
    );
    // WorkoutModeBloc: mod listesi değişmez → singleton yeterli.
    sl.registerLazySingleton<WorkoutModeBloc>(
      () => WorkoutModeBloc(repository: sl())..add(const WorkoutModesLoaded()),
    );
  }
}
