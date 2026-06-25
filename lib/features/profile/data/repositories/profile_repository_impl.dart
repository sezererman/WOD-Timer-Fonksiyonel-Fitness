import 'dart:io';

import '../../../../core/error/exceptions.dart';
import '../../../community/domain/entities/comment_entity.dart';
import '../../../community/domain/entities/workout_share_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  /// Tekrar eden try-catch kalıbını tek yerden yönetir (DRY).
  Future<T> _wrap<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (e) {
      if (e is DatabaseException) rethrow;
      if (e is StorageException) rethrow;
      throw const DatabaseException('Beklenmeyen bir hata oluştu');
    }
  }

  @override
  Future<UserProfileEntity> updateProfileDetails({
    required String userId,
    String? bio,
    String? favoriteMove,
  }) =>
      _wrap(() async {
        await remoteDataSource.updateProfileDetails(
          userId: userId,
          bio: bio,
          favoriteMove: favoriteMove,
        );
        return await remoteDataSource.getUserProfile(userId);
      });

  @override
  Future<UserProfileEntity> getUserProfile(String userId) =>
      _wrap(() => remoteDataSource.getUserProfile(userId));

  @override
  Future<List<WorkoutShareEntity>> getSharedWorkouts(String userId) =>
      _wrap(() => remoteDataSource.getSharedWorkouts(userId));

  @override
  Future<List<CommentEntity>> getUserComments(String userId) =>
      _wrap(() => remoteDataSource.getUserComments(userId));

  @override
  Future<List<WorkoutShareEntity>> getLikedWorkouts(String userId) =>
      _wrap(() => remoteDataSource.getLikedWorkouts(userId));

  @override
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) =>
      _wrap(() => remoteDataSource.uploadAvatar(
            userId: userId,
            imageFile: imageFile,
          ));
}

