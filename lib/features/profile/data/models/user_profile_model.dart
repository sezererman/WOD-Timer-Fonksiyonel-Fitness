import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    super.name,
    super.avatarUrl,
    super.bio,
    super.favoriteMove,
    super.totalWorkouts,
    super.totalLikes,
    super.totalComments,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      favoriteMove: json['favorite_move'] as String?,
      // These fields might not be in the users table, we can fetch them separately
      // or using a joined query/view. 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'bio': bio,
      'favorite_move': favoriteMove,
    };
  }
}
