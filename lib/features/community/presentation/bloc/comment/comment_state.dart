import 'package:equatable/equatable.dart';
import '../../../domain/entities/comment_entity.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentLoaded extends CommentState {
  final List<CommentEntity> comments;
  final bool hasReachedMax;
  final bool isPaginating;

  const CommentLoaded({
    required this.comments,
    this.hasReachedMax = false,
    this.isPaginating = false,
  });

  CommentLoaded copyWith({
    List<CommentEntity>? comments,
    bool? hasReachedMax,
    bool? isPaginating,
  }) {
    return CommentLoaded(
      comments: comments ?? this.comments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isPaginating: isPaginating ?? this.isPaginating,
    );
  }

  @override
  List<Object?> get props => [comments, hasReachedMax, isPaginating];
}

class CommentError extends CommentState {
  final String message;

  const CommentError(this.message);

  @override
  List<Object?> get props => [message];
}

class CommentActionSuccess extends CommentState {
  final String message;

  const CommentActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CommentActionError extends CommentState {
  final String message;

  const CommentActionError(this.message);

  @override
  List<Object?> get props => [message];
}
