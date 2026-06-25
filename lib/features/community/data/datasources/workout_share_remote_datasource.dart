import '../models/workout_share_model.dart';

abstract class WorkoutShareRemoteDataSource {
  Future<void> shareWorkout(WorkoutShareModel workoutShare);
  Future<List<WorkoutShareModel>> getSharedWorkouts({required int limit, required int offset});
  Future<void> toggleLike({required String workoutId, required bool isLiking});
}
