import 'package:get_it/get_it.dart';

import '../../../features/timer/data/datasources/audio_service.dart';
import '../../../features/timer/data/repositories/audio_repository_impl.dart';
import '../../../features/timer/domain/repositories/audio_repository.dart';
import '../../../features/timer/domain/usecases/play_timer_sound_use_case.dart';
import '../../../features/timer/data/datasources/timer_local_datasource.dart';
import '../../../features/timer/data/repositories/timer_repository_impl.dart';
import '../../../features/timer/domain/repositories/timer_repository.dart';
import '../../../features/timer/presentation/bloc/timer_bloc.dart';
import '../../../features/timer/presentation/observers/timer_observer.dart';

/// Timer feature bağımlılıklarını kaydeder.
abstract final class TimerModule {
  static void register(GetIt sl) {
    sl.registerLazySingleton<AudioService>(() => AudioService());
    sl.registerLazySingleton<AudioRepository>(
      () => AudioRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<PlayTimerSoundUseCase>(
      () => PlayTimerSoundUseCase(sl()),
    );
    sl.registerLazySingleton<TimerLocalDatasource>(
      () => TimerLocalDatasource(sl()),
    );
    sl.registerLazySingleton<TimerRepository>(
      () => TimerRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<WorkoutAutoSaveObserver>(
      () => WorkoutAutoSaveObserver(
        saveWorkout: sl(),
        syncService: sl(),
      ),
    );
    sl.registerLazySingleton<TimerBloc>(
      () => TimerBloc(
        ticker: sl(),
        playTimerSound: sl(),
        observers: [sl<WorkoutAutoSaveObserver>()],
      ),
    );
  }
}
