import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/timer_config.dart';
import '../../../history/domain/entities/workout_record.dart';
import '../../../history/domain/usecases/save_workout.dart';
import '../../domain/entities/timer_phase.dart';

/// Timer durum değişikliklerini izlemek için arayüz (Observer Pattern).
/// "Tell, Don't Ask" prensibine uygun olarak açık (explicit) metotlar içerir.
abstract class TimerObserver {
  void onPhaseChanged(TimerPhase phase) {}
  void onRoundCompleted(int round) {}
  void onWorkoutCompleted(TimerConfig config, int totalElapsedSeconds) {}
}

/// Antrenman bittiğinde otomatik olarak veritabanına kaydeden observer.
class WorkoutAutoSaveObserver implements TimerObserver {
  final SaveWorkout _saveWorkout;
  final Uuid _uuid = const Uuid();

  WorkoutAutoSaveObserver({required SaveWorkout saveWorkout}) : _saveWorkout = saveWorkout;

  @override
  void onWorkoutCompleted(TimerConfig config, int totalElapsedSeconds) {
    final now = DateTime.now();
    final record = WorkoutRecord(
      id: _uuid.v4(),
      modeName: config.modeDisplayName, // LoD ihlali düzeltildi
      totalSeconds: totalElapsedSeconds,
      rounds: config.rounds,
      workSeconds: config.workSeconds,
      restSeconds: config.restSeconds,
      date: now,
    );

    _saveWithErrorHandling(record);
  }

  @override
  void onPhaseChanged(TimerPhase phase) {}

  @override
  void onRoundCompleted(int round) {}

  Future<void> _saveWithErrorHandling(WorkoutRecord record) async {
    try {
      await _saveWorkout(record);
    } catch (e) {
      debugPrint('Failed to save workout: $e');
    }
  }
}
