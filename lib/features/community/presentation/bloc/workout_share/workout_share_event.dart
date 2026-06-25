import 'package:equatable/equatable.dart';

abstract class WorkoutShareEvent extends Equatable {
  const WorkoutShareEvent();

  @override
  List<Object?> get props => [];
}

class FetchSharedWorkoutsEvent extends WorkoutShareEvent {}

class ToggleLikeEvent extends WorkoutShareEvent {
  final String workoutId;
  final String currentUserId;

  const ToggleLikeEvent({
    required this.workoutId,
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [workoutId, currentUserId];
}

class SyncLikeServerEvent extends WorkoutShareEvent {
  final String workoutId;
  final bool isLiking;
  final List<dynamic> originalPosts; // Hata durumunda Rollback için

  const SyncLikeServerEvent({
    required this.workoutId,
    required this.isLiking,
    required this.originalPosts,
  });

  @override
  List<Object?> get props => [workoutId, isLiking, originalPosts];
}
