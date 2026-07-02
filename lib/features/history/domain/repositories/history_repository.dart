import '../entities/workout_record.dart';

/// Antrenman geçmişi repository arayüzü.
abstract class HistoryRepository {
  Future<List<WorkoutRecord>> getHistory();
  Future<void> saveWorkout(WorkoutRecord record);
  Future<void> deleteWorkout(String id);
  Future<List<WorkoutRecord>> getPendingWorkouts();
  Future<void> updateSyncStatus(String id, String status);
}
