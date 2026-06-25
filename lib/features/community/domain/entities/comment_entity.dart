import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String workoutId;
  final String userId;
  final String text;
  final DateTime createdAt;
  final String? workoutTitle;

  const CommentEntity({
    required this.id,
    required this.workoutId,
    required this.userId,
    required this.text,
    required this.createdAt,
    this.workoutTitle,
  });

  @override
  List<Object?> get props => [id, workoutId, userId, text, createdAt, workoutTitle];
}
