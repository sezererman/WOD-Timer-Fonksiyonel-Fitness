import 'package:equatable/equatable.dart';
import '../../../domain/entities/workout_share_entity.dart';

abstract class WorkoutShareState extends Equatable {
  const WorkoutShareState();

  @override
  List<Object?> get props => [];
}

class WorkoutShareInitial extends WorkoutShareState {}

class WorkoutShareLoading extends WorkoutShareState {}

class WorkoutShareLoaded extends WorkoutShareState {
  final List<WorkoutShareEntity> posts;
  final bool hasReachedMax;

  const WorkoutShareLoaded({
    required this.posts,
    this.hasReachedMax = false,
  });

  WorkoutShareLoaded copyWith({
    List<WorkoutShareEntity>? posts,
    bool? hasReachedMax,
  }) {
    return WorkoutShareLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [posts, hasReachedMax];
}

class WorkoutShareError extends WorkoutShareState {
  final String message;

  const WorkoutShareError(this.message);

  @override
  List<Object?> get props => [message];
}

class WorkoutShareOptimisticError extends WorkoutShareState {
  final String message;
  final List<WorkoutShareEntity> rolledBackPosts;

  const WorkoutShareOptimisticError(this.message, this.rolledBackPosts);

  @override
  List<Object?> get props => [message, rolledBackPosts];
}
