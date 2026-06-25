import '../models/workout_share_model.dart';

abstract class WorkoutShareLocalDataSource {
  Future<void> cacheSharedWorkouts(List<WorkoutShareModel> workouts);
  Future<List<WorkoutShareModel>> getCachedSharedWorkouts();
  Future<void> clearCache();
}
