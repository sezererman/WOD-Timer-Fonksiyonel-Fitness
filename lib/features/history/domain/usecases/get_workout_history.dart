import '../../../../core/usecases/usecase.dart';
import '../entities/workout_record.dart';
import '../repositories/history_repository.dart';

/// Antrenman geçmişini getirme use case'i.
class GetWorkoutHistory extends UseCase<List<WorkoutRecord>, NoParams> {
  final HistoryRepository _repository;
  GetWorkoutHistory(this._repository);

  @override
  Future<List<WorkoutRecord>> call(NoParams params) {
    return _repository.getHistory();
  }
}
