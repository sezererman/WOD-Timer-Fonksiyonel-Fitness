// Removed dartz dependency
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileDetailsParams {
  final String userId;
  final String? bio;
  final String? favoriteMove;

  const UpdateProfileDetailsParams({
    required this.userId,
    this.bio,
    this.favoriteMove,
  });
}

class UpdateProfileDetailsUseCase {
  final ProfileRepository repository;

  UpdateProfileDetailsUseCase(this.repository);

  Future<UserProfileEntity> call(UpdateProfileDetailsParams params) async {
    return await repository.updateProfileDetails(
      userId: params.userId,
      bio: params.bio,
      favoriteMove: params.favoriteMove,
    );
  }
}
