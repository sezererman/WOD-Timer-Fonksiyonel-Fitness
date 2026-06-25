import '../../domain/entities/workout_preset.dart';
import '../../domain/entities/workout_mode.dart';

/// Workout preset model — Hive serileştirme.
class WorkoutPresetModel {
  final String name;
  final String mode;
  final int rounds;
  final int workSeconds;
  final int restSeconds;
  final int prepareSeconds;

  const WorkoutPresetModel({
    required this.name,
    required this.mode,
    required this.rounds,
    required this.workSeconds,
    required this.restSeconds,
    required this.prepareSeconds,
  });

  factory WorkoutPresetModel.fromEntity(WorkoutPreset entity) {
    return WorkoutPresetModel(
      name: entity.name,
      mode: entity.mode.name,
      rounds: entity.rounds,
      workSeconds: entity.workSeconds,
      restSeconds: entity.restSeconds,
      prepareSeconds: entity.prepareSeconds,
    );
  }

  factory WorkoutPresetModel.fromMap(Map<String, dynamic> map) {
    return WorkoutPresetModel(
      name: map['name'] as String? ?? '',
      mode: map['mode'] as String? ?? 'custom',
      rounds: map['rounds'] as int? ?? 1,
      workSeconds: map['workSeconds'] as int? ?? 60,
      restSeconds: map['restSeconds'] as int? ?? 0,
      prepareSeconds: map['prepareSeconds'] as int? ?? 10,
    );
  }

  WorkoutPreset toEntity() {
    return WorkoutPreset(
      name: name,
      mode: WorkoutMode.values.firstWhere(
        (m) => m.name == mode,
        orElse: () => WorkoutMode.custom,
      ),
      rounds: rounds,
      workSeconds: workSeconds,
      restSeconds: restSeconds,
      prepareSeconds: prepareSeconds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mode': mode,
      'rounds': rounds,
      'workSeconds': workSeconds,
      'restSeconds': restSeconds,
      'prepareSeconds': prepareSeconds,
    };
  }
}
