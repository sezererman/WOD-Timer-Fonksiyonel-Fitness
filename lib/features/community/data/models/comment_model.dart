import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.workoutId,
    required super.userId,
    required super.text,
    required super.createdAt,
    super.workoutTitle,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      workoutId: json['workout_id'] as String,
      userId: json['user_id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      workoutTitle: json['shared_workouts'] != null
          ? (json['shared_workouts'] as Map<String, dynamic>)['workout_type'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'user_id': userId,
      'text': text,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      workoutId: entity.workoutId,
      userId: entity.userId,
      text: entity.text,
      createdAt: entity.createdAt,
      workoutTitle: entity.workoutTitle,
    );
  }
}
