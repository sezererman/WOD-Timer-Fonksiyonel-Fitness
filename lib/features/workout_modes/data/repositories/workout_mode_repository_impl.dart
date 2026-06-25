import '../../../../core/constants/app_durations.dart';
import '../../domain/entities/workout_mode.dart';
import '../../domain/entities/workout_preset.dart';
import '../../domain/repositories/workout_mode_repository.dart';
import '../datasources/workout_mode_local_datasource.dart';

/// WorkoutModeRepository somut uygulaması.
class WorkoutModeRepositoryImpl implements WorkoutModeRepository {
  final WorkoutModeLocalDatasource _datasource;

  WorkoutModeRepositoryImpl(this._datasource);

  @override
  List<WorkoutMode> getAvailableModes() {
    return WorkoutMode.values;
  }

  @override
  List<WorkoutPreset> getPresetsForMode(WorkoutMode mode) {
    switch (mode) {
      case WorkoutMode.tabata:
        return const [
          WorkoutPreset(
            name: 'Klasik Tabata',
            mode: WorkoutMode.tabata,
            rounds: AppDurations.tabataDefaultRounds,
            workSeconds: AppDurations.tabataWorkSeconds,
            restSeconds: AppDurations.tabataRestSeconds,
          ),
          WorkoutPreset(
            name: 'Uzun Tabata',
            mode: WorkoutMode.tabata,
            rounds: 12,
            workSeconds: 30,
            restSeconds: 15,
          ),
        ];
      case WorkoutMode.emom:
        return const [
          WorkoutPreset(
            name: '10 Dk EMOM',
            mode: WorkoutMode.emom,
            rounds: AppDurations.emomDefaultRounds,
            workSeconds: 60,
          ),
          WorkoutPreset(
            name: '20 Dk EMOM',
            mode: WorkoutMode.emom,
            rounds: 20,
            workSeconds: 60,
          ),
        ];
      case WorkoutMode.amrap:
        return const [
          WorkoutPreset(
            name: '12 Dk AMRAP',
            mode: WorkoutMode.amrap,
            rounds: 1,
            workSeconds: 720,
          ),
          WorkoutPreset(
            name: '20 Dk AMRAP',
            mode: WorkoutMode.amrap,
            rounds: 1,
            workSeconds: 1200,
          ),
        ];
      case WorkoutMode.forTime:
        return const [
          WorkoutPreset(
            name: '15 Dk For Time',
            mode: WorkoutMode.forTime,
            rounds: 1,
            workSeconds: 900,
          ),
        ];
      case WorkoutMode.custom:
        return const [
          WorkoutPreset(
            name: 'Özel Zamanlayıcı',
            mode: WorkoutMode.custom,
            rounds: AppDurations.defaultRounds,
            workSeconds: AppDurations.defaultWorkSeconds,
            restSeconds: AppDurations.defaultRestSeconds,
          ),
        ];
    }
  }

  @override
  Future<void> savePreset(WorkoutPreset preset) {
    return _datasource.savePreset(preset);
  }

  @override
  Future<List<WorkoutPreset>> getUserPresets() {
    return _datasource.getUserPresets();
  }
}
