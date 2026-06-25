import '../../../../core/usecases/usecase.dart';
import '../repositories/history_repository.dart';

/// Antrenman kaydını silme use case'i.
class DeleteWorkout extends UseCase<void, String> {
  final HistoryRepository _repository;
  DeleteWorkout(this._repository);

  @override
  Future<void> call(String params) {
    return _repository.deleteWorkout(params);
  }
}
