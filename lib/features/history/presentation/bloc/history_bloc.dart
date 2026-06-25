import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/save_workout.dart';
import '../../domain/usecases/get_workout_history.dart';
import '../../domain/usecases/delete_workout.dart';
import '../../domain/usecases/sync_badges_usecase.dart';
import '../../domain/services/i_history_statistics_service.dart';
import 'history_event.dart';
import 'history_state.dart';

/// Antrenman geçmişi ve rozet yönetimini koordine eden BLoC.
///
/// Clean Architecture kuralı: Presentation katmanı yalnızca UseCase'leri çağırır.
/// BadgeLocalDatasource veya HistoryLocalDatasource'a hiçbir zaman doğrudan bağlanmaz.
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetWorkoutHistory _getWorkoutHistory;
  final SaveWorkout _saveWorkout;
  final DeleteWorkout _deleteWorkout;
  final IHistoryStatisticsService _statsService;
  final SyncBadgesUseCase _syncBadges;

  HistoryBloc({
    required GetWorkoutHistory getWorkoutHistory,
    required SaveWorkout saveWorkout,
    required DeleteWorkout deleteWorkout,
    required IHistoryStatisticsService statsService,
    required SyncBadgesUseCase syncBadges,
  })  : _getWorkoutHistory = getWorkoutHistory,
        _saveWorkout = saveWorkout,
        _deleteWorkout = deleteWorkout,
        _statsService = statsService,
        _syncBadges = syncBadges,
        super(const HistoryInitial()) {
    on<HistoryLoaded>(_onLoaded);
    on<HistoryWorkoutSaved>(_onSaved);
    on<HistoryWorkoutDeleted>(_onDeleted);
  }

  Future<void> _onLoaded(HistoryLoaded event, Emitter<HistoryState> emit) async {
    try {
      final records = await _getWorkoutHistory(const NoParams());
      final stats = _statsService.calculate(records);

      // Rozet senkronizasyonu tek UseCase çağrısıyla tamamlanıyor —
      // BLoC Data Layer'a (datasource) hiç dokunmuyor.
      final badges = await _syncBadges(records);

      emit(HistoryLoadSuccess(
        records: records,
        stats: stats,
        earnedBadges: badges,
      ));
    } catch (e) {
      emit(HistoryError('Geçmiş yüklenirken hata oluştu: $e'));
    }
  }

  Future<void> _onSaved(HistoryWorkoutSaved event, Emitter<HistoryState> emit) async {
    await _mutateAndReload(() => _saveWorkout(event.record), emit);
  }

  Future<void> _onDeleted(HistoryWorkoutDeleted event, Emitter<HistoryState> emit) async {
    await _mutateAndReload(() => _deleteWorkout(event.id), emit);
  }

  /// Save/Delete işlemlerindeki tekrar eden "mutate → reload" akışını tek yerden yönetir (DRY).
  ///
  /// Hata durumunda [HistoryError] emit eder — sessiz hata (silent failure) önlenir.
  Future<void> _mutateAndReload(
    Future<void> Function() mutation,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryMutating());
    try {
      await mutation();
      add(const HistoryLoaded());
    } catch (e) {
      emit(HistoryError('İşlem başarısız: $e'));
    }
  }
}

