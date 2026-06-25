import '../../../../core/usecases/usecase.dart';
import '../entities/workout_record.dart';
import '../repositories/history_repository.dart';

/// Antrenman kaydını kaydetme use case'i.
class SaveWorkout extends UseCase<void, WorkoutRecord> {
  final HistoryRepository _repository;
  SaveWorkout(this._repository);

  @override
  Future<void> call(WorkoutRecord params) {
    return _repository.saveWorkout(params);
  }
}
