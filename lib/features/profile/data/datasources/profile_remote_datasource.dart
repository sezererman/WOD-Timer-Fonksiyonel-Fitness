import 'dart:io';

import '../../../community/data/models/comment_model.dart';
import '../../../community/data/models/workout_share_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);
  Future<List<WorkoutShareModel>> getSharedWorkouts(String userId);
  Future<List<CommentModel>> getUserComments(String userId);
  Future<List<WorkoutShareModel>> getLikedWorkouts(String userId);

  /// Fotoğrafı [avatars] bucket'ına yükler, [users.avatar_url]'i günceller.
  /// Geri dönüş: public URL.
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  });

  Future<void> updateProfileDetails({
    required String userId,
    String? bio,
    String? favoriteMove,
  });
}

