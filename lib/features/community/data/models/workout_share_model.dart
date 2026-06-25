import '../../domain/entities/workout_share_entity.dart';
import 'exercise_model.dart';

class WorkoutShareModel extends WorkoutShareEntity {
  const WorkoutShareModel({
    required super.id,
    required super.userId,
    super.userName,
    super.userAvatarUrl,
    super.userLevel,
    required super.workoutType,
    required super.durationSeconds,
    super.score,
    required super.date,
    super.notes,
    super.likesCount,
    super.likedUserIds,
    super.exercises,
  });

  factory WorkoutShareModel.fromJson(Map<String, dynamic> json) {
    // JOIN sorgusundan gelen users objesini parse edelim
    String? parsedUserName;
    String? parsedAvatarUrl;
    if (json['users'] != null) {
      final users = json['users'] as Map<String, dynamic>;
      parsedUserName = users['name'] as String?;
      parsedAvatarUrl = users['avatar_url'] as String?;
    }

    // user_xp_profiles JOIN'dan gelen seviye bilgisi
    int? parsedUserLevel;
    if (json['users'] != null && (json['users'] as Map<String, dynamic>)['user_xp_profiles'] != null) {
      final xp = (json['users'] as Map<String, dynamic>)['user_xp_profiles'];
      if (xp is Map<String, dynamic>) {
        parsedUserLevel = xp['current_level'] as int?;
      } else if (xp is List && xp.isNotEmpty) {
        parsedUserLevel = (xp.first as Map<String, dynamic>)['current_level'] as int?;
      }
    } else if (json['user_xp_profiles'] != null) {
      final xp = json['user_xp_profiles'];
      if (xp is Map<String, dynamic>) {
        parsedUserLevel = xp['current_level'] as int?;
      } else if (xp is List && xp.isNotEmpty) {
        parsedUserLevel = (xp.first as Map<String, dynamic>)['current_level'] as int?;
      }
    }

    return WorkoutShareModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: parsedUserName,
      userAvatarUrl: parsedAvatarUrl,
      userLevel: parsedUserLevel,
      workoutType: json['workout_type'] as String,
      durationSeconds: (json['total_time'] ?? json['duration_seconds']) as int,
      score: (json['rounds'] ?? json['score']) as int?,
      date: DateTime.parse((json['created_at'] ?? json['date']) as String),
      notes: json['notes'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      likedUserIds: (json['liked_user_ids'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'workout_type': workoutType,
      'total_time': durationSeconds,
      'rounds': score ?? 0,
      'created_at': date.toIso8601String(),
      'notes': notes,
      'likes_count': likesCount,
      'liked_user_ids': likedUserIds,
      'exercises': exercises.map((e) => ExerciseModel.fromEntity(e).toJson()).toList(),
    };
  }

  factory WorkoutShareModel.fromEntity(WorkoutShareEntity entity) {
    return WorkoutShareModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      userAvatarUrl: entity.userAvatarUrl,
      userLevel: entity.userLevel,
      workoutType: entity.workoutType,
      durationSeconds: entity.durationSeconds,
      score: entity.score,
      date: entity.date,
      notes: entity.notes,
      likesCount: entity.likesCount,
      likedUserIds: entity.likedUserIds,
      exercises: entity.exercises,
    );
  }
}
