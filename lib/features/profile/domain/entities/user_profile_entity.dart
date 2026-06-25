import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String? name;
  final String? avatarUrl;
  final String? bio;
  final String? favoriteMove;
  final int totalWorkouts;
  final int totalLikes;
  final int totalComments;

  const UserProfileEntity({
    required this.id,
    this.name,
    this.avatarUrl,
    this.bio,
    this.favoriteMove,
    this.totalWorkouts = 0,
    this.totalLikes = 0,
    this.totalComments = 0,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        avatarUrl,
        bio,
        favoriteMove,
        totalWorkouts,
        totalLikes,
        totalComments,
      ];
}
