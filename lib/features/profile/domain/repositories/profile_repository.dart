import 'dart:io';

import '../../../community/domain/entities/comment_entity.dart';
import '../../../community/domain/entities/workout_share_entity.dart';
import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<UserProfileEntity> getUserProfile(String userId);
  Future<List<WorkoutShareEntity>> getSharedWorkouts(String userId);
  Future<List<CommentEntity>> getUserComments(String userId);
  Future<List<WorkoutShareEntity>> getLikedWorkouts(String userId);

  /// Kullanıcının avatarını [avatars] bucket'ına yükler ve
  /// [users] tablosundaki [avatar_url] alanını günceller.
  ///
  /// Geri dönüş: Yüklenen dosyanın public URL'i.
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  });

  Future<UserProfileEntity> updateProfileDetails({
    required String userId,
    String? bio,
    String? favoriteMove,
  });
}
