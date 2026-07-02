import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/timer_config.dart';
import '../../../history/domain/entities/workout_record.dart';
import '../../../history/domain/usecases/save_workout.dart';
import '../../domain/entities/timer_phase.dart';
import '../../../../infrastructure/services/workout_sync_service.dart';

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
  final WorkoutSyncService _syncService;
  final Uuid _uuid = const Uuid();

  WorkoutAutoSaveObserver({
    required SaveWorkout saveWorkout,
    required WorkoutSyncService syncService,
  }) : _saveWorkout = saveWorkout,
       _syncService = syncService;

  @override
  void onWorkoutCompleted(TimerConfig config, int totalElapsedSeconds) {
    final now = DateTime.now();
    // Kayıt önce lokal Hive'a SyncStatus.pending ile kaydedilir (varsayılan değer).
    // Ardından _saveWithErrorHandling içinde sync servisi tetiklenir.
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
      // Lokal veritabanına kaydettikten sonra arka plan senkronizasyonu başlat
      await _syncService.syncPendingWorkouts();
    } catch (e) {
      debugPrint('Failed to save workout: $e');
    }
  }
}
