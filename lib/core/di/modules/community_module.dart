import 'package:get_it/get_it.dart';

import '../../../features/community/data/datasources/supabase_social_datasource.dart';
import '../../../features/community/data/datasources/workout_share_remote_datasource.dart';
import '../../../features/community/data/datasources/workout_share_remote_datasource_impl.dart';
import '../../../features/community/data/datasources/workout_share_local_datasource.dart';
import '../../../features/community/data/datasources/workout_share_local_datasource_impl.dart';
import '../../../features/community/data/repositories/workout_share_repository_impl.dart';
import '../../../features/community/domain/repositories/workout_share_repository.dart';
import '../../../features/community/presentation/bloc/workout_share/workout_share_bloc.dart';

/// Community feature bağımlılıklarını kaydeder.
abstract final class CommunityModule {
  static void register(GetIt sl) {
    sl.registerLazySingleton<WorkoutShareLocalDataSource>(
      () => WorkoutShareLocalDataSourceImpl(),
    );
    sl.registerLazySingleton<WorkoutShareRemoteDataSource>(
      () => WorkoutShareRemoteDataSourceImpl(supabaseClient: sl()),
    );
    sl.registerLazySingleton<SupabaseSocialDataSource>(
      () => SupabaseSocialDataSource(supabaseClient: sl()),
    );
    sl.registerLazySingleton<WorkoutShareRepository>(
      () => WorkoutShareRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ),
    );
    // WorkoutShareBloc: singleton — community tab geçişlerinde state korunur.
    sl.registerLazySingleton<WorkoutShareBloc>(
      () => WorkoutShareBloc(repository: sl()),
    );
  }
}
