import '../../domain/entities/workout_record.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDatasource _datasource;
  HistoryRepositoryImpl(this._datasource);

  @override
  Future<List<WorkoutRecord>> getHistory() => _datasource.getHistory();

  @override
  Future<void> saveWorkout(WorkoutRecord record) =>
      _datasource.saveWorkout(record);

  @override
  Future<void> deleteWorkout(String id) => _datasource.deleteWorkout(id);

  @override
  Future<List<WorkoutRecord>> getPendingWorkouts() =>
      _datasource.getPendingWorkouts();

  @override
  Future<void> updateSyncStatus(String id, String status) =>
      _datasource.updateSyncStatus(id, status);
}
