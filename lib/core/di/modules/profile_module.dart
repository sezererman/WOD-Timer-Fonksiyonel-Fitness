import 'package:get_it/get_it.dart';

import '../../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../../features/profile/data/datasources/profile_remote_datasource_impl.dart';
import '../../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../../features/profile/data/services/avatar_picker_service_impl.dart';
import '../../../features/profile/domain/repositories/profile_repository.dart';
import '../../../features/profile/domain/services/avatar_picker_service.dart';
import '../../../features/profile/domain/usecases/upload_avatar_usecase.dart';
import '../../../features/profile/domain/usecases/update_profile_details_usecase.dart';
import '../../../features/profile/presentation/bloc/profile_bloc.dart';

/// Profile feature bağımlılıklarını kaydeder.
abstract final class ProfileModule {
  static void register(GetIt sl) {
    sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(supabaseClient: sl()),
    );
    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerLazySingleton<UploadAvatarUseCase>(
      () => UploadAvatarUseCase(sl()),
    );
    sl.registerLazySingleton<UpdateProfileDetailsUseCase>(
      () => UpdateProfileDetailsUseCase(sl()),
    );
    // Platform UI detayları burada kapsüllenir.
    sl.registerLazySingleton<AvatarPickerService>(
      () => AvatarPickerServiceImpl(),
    );
    sl.registerFactory<ProfileBloc>(
      () => ProfileBloc(
        profileRepository: sl(),
        uploadAvatarUseCase: sl(),
        updateProfileDetailsUseCase: sl(),
        avatarPickerService: sl(),
      ),
    );
  }
}
