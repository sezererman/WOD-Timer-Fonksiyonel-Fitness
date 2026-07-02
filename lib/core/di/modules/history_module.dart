import 'package:get_it/get_it.dart';

import '../../../features/history/data/datasources/history_local_datasource.dart';
import '../../../features/history/data/datasources/badge_local_datasource.dart';
import '../../../features/history/data/repositories/history_repository_impl.dart';
import '../../../features/history/data/repositories/badge_repository_impl.dart';
import '../../../features/history/domain/repositories/history_repository.dart';
import '../../../features/history/domain/repositories/badge_repository.dart';
import '../../../features/history/domain/usecases/save_workout.dart';
import '../../../features/history/domain/usecases/get_workout_history.dart';
import '../../../features/history/domain/usecases/delete_workout.dart';
import '../../../features/history/domain/usecases/sync_badges_usecase.dart';
import '../../../features/history/domain/usecases/check_and_award_badges.dart';
import '../../../features/history/domain/services/badge_service.dart';
import '../../../features/history/domain/services/history_statistics_service.dart';
import '../../../features/history/domain/services/i_history_statistics_service.dart';
import '../../../infrastructure/services/workout_sync_service.dart';
import '../../../features/history/presentation/bloc/badges_bloc.dart';
import '../../../features/history/presentation/bloc/history_bloc.dart';

/// History feature bağımlılıklarını kaydeder.
abstract final class HistoryModule {
  static void register(GetIt sl) {
    sl.registerLazySingleton<HistoryLocalDatasource>(
      () => HistoryLocalDatasource(sl()),
    );
    sl.registerLazySingleton<BadgeLocalDatasource>(
      () => BadgeLocalDatasource(sl()),
    );
    sl.registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(sl()),
    );
    // BadgeRepository: BLoC doğrudan datasource'a değil, bu interface'e bağlı.
    sl.registerLazySingleton<BadgeRepository>(
      () => BadgeRepositoryImpl(sl()),
    );
    // IHistoryStatisticsService arayüzüne bağlanır — test'te mock'lanabilir.
    sl.registerLazySingleton<IHistoryStatisticsService>(
      () => HistoryStatisticsService(),
    );
    sl.registerLazySingleton<BadgeService>(() => BadgeService());
    sl.registerLazySingleton<GetWorkoutHistory>(() => GetWorkoutHistory(sl()));
    sl.registerLazySingleton<SaveWorkout>(() => SaveWorkout(sl()));
    sl.registerLazySingleton<DeleteWorkout>(() => DeleteWorkout(sl()));
    sl.registerLazySingleton<SyncBadgesUseCase>(
      () => SyncBadgesUseCase(repository: sl(), badgeService: sl()),
    );
    sl.registerLazySingleton<CheckAndAwardBadgesUseCase>(
      () => CheckAndAwardBadgesUseCase(repository: sl(), badgeService: sl()),
    );
    sl.registerLazySingleton<WorkoutSyncService>(
      () => WorkoutSyncService(
        supabaseClient: sl(),
        historyRepository: sl(),
      ),
    );
    sl.registerFactory<BadgesBloc>(
      () => BadgesBloc(
        checkAndAwardBadges: sl(),
        historyRepository: sl(),
      ),
    );
    // HistoryBloc: app genelinde tek instance — geçmiş tab'ında state korunur.
    sl.registerLazySingleton<HistoryBloc>(
      () => HistoryBloc(
        getWorkoutHistory: sl(),
        saveWorkout: sl(),
        deleteWorkout: sl(),
        statsService: sl(),
        syncBadges: sl(),
      ),
    );
  }
}
