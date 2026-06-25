import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class LoadCommentsEvent extends CommentEvent {
  final String workoutId;

  const LoadCommentsEvent(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}

class LoadMoreCommentsEvent extends CommentEvent {
  final String workoutId;

  const LoadMoreCommentsEvent(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}

class AddCommentEvent extends CommentEvent {
  final String workoutId;
  final String text;

  const AddCommentEvent({required this.workoutId, required this.text});

  @override
  List<Object?> get props => [workoutId, text];
}

class DeleteCommentEvent extends CommentEvent {
  final String commentId;
  final String commentUserId; // Yorumun sahibi kim? (Yetki kontrolü için)

  const DeleteCommentEvent({required this.commentId, required this.commentUserId});

  @override
  List<Object?> get props => [commentId, commentUserId];
}

class ReportCommentEvent extends CommentEvent {
  final String commentId;
  final String commentUserId; // Başkasının yorumu mu kontrolü için
  final String reason;

  const ReportCommentEvent({
    required this.commentId,
    required this.commentUserId,
    required this.reason,
  });

  @override
  List<Object?> get props => [commentId, commentUserId, reason];
}
