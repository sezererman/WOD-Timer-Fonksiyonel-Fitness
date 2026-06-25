import '../entities/workout_share_entity.dart';

abstract class WorkoutShareRepository {
  /// Antrenmanı toplulukla paylaşır
  Future<void> shareWorkout(WorkoutShareEntity workoutShare);

  /// Paylaşılan antrenmanları sayfalı şekilde çeker (Pagination)
  Future<List<WorkoutShareEntity>> getSharedWorkouts({
    required int limit,
    required int offset,
  });

  /// Bir gönderiyi beğenir veya beğeniyi geri alır (Atomic Toggle)
  Future<void> toggleLike({
    required String workoutId,
    required bool isLiking,
  });
}
