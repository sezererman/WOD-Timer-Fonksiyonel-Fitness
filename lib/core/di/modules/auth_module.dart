import 'package:get_it/get_it.dart';

import '../../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../../features/auth/data/repositories/supabase_auth_repository_impl.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../../features/auth/domain/usecases/listen_auth_state_change_usecase.dart';
import '../../../features/auth/domain/usecases/login_usecase.dart';
import '../../../features/auth/domain/usecases/register_usecase.dart';
import '../../../features/auth/domain/usecases/signout_usecase.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';

/// Auth feature bağımlılıklarını kaydeder.
abstract final class AuthModule {
  static void register(GetIt sl) {
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(secureStorage: sl()),
    );
    sl.registerLazySingleton<AuthRepository>(
      () => SupabaseAuthRepositoryImpl(
        supabaseClient: sl(),
        localDataSource: sl(),
      ),
    );
    sl.registerLazySingleton<ListenAuthStateChangeUseCase>(
      () => ListenAuthStateChangeUseCase(sl()),
    );
    sl.registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(sl()),
    );
    sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
    sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl()));
    sl.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase(sl()));
    sl.registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        signOutUseCase: sl(),
        getCurrentUserUseCase: sl(),
        listenAuthStateChangeUseCase: sl(),
      )..add(const AppStarted()),
    );
  }
}
