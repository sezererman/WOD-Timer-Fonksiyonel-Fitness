import '../../domain/entities/timer_config.dart';
import '../../../workout_modes/domain/entities/workout_mode.dart';

/// TimerConfig'in Hive serileştirme modeli.
class TimerConfigModel {
  final int rounds;
  final int workSeconds;
  final int restSeconds;
  final int prepareSeconds;
  final int cooldownSeconds;
  final WorkoutMode? mode;
  final bool requiresManualRoundIncrement;

  const TimerConfigModel({
    required this.rounds,
    required this.workSeconds,
    required this.restSeconds,
    required this.prepareSeconds,
    required this.cooldownSeconds,
    this.mode,
    required this.requiresManualRoundIncrement,
  });

  /// Entity'den model oluşturur.
  factory TimerConfigModel.fromEntity(TimerConfig entity) {
    return TimerConfigModel(
      rounds: entity.rounds,
      workSeconds: entity.workSeconds,
      restSeconds: entity.restSeconds,
      prepareSeconds: entity.prepareSeconds,
      cooldownSeconds: entity.cooldownSeconds,
      mode: entity.mode,
      requiresManualRoundIncrement: entity.requiresManualRoundIncrement,
    );
  }

  /// Hive Map'inden model oluşturur.
  factory TimerConfigModel.fromMap(Map<String, dynamic> map) {
    return TimerConfigModel(
      rounds: map['rounds'] as int? ?? 1,
      workSeconds: map['workSeconds'] as int? ?? 60,
      restSeconds: map['restSeconds'] as int? ?? 30,
      prepareSeconds: map['prepareSeconds'] as int? ?? 10,
      cooldownSeconds: map['cooldownSeconds'] as int? ?? 0,
      mode: map['mode'] != null
          ? WorkoutMode.values.firstWhere(
              (e) => e.name == map['mode'],
              orElse: () => WorkoutMode.custom,
            )
          : null,
      requiresManualRoundIncrement:
          map['requiresManualRoundIncrement'] as bool? ?? false,
    );
  }

  /// Domain entity'ye dönüştürür.
  TimerConfig toEntity() {
    return TimerConfig(
      rounds: rounds,
      workSeconds: workSeconds,
      restSeconds: restSeconds,
      prepareSeconds: prepareSeconds,
      cooldownSeconds: cooldownSeconds,
      mode: mode,
      requiresManualRoundIncrement: requiresManualRoundIncrement,
    );
  }

  /// Hive için Map'e dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'rounds': rounds,
      'workSeconds': workSeconds,
      'restSeconds': restSeconds,
      'prepareSeconds': prepareSeconds,
      'cooldownSeconds': cooldownSeconds,
      'mode': mode?.name,
      'requiresManualRoundIncrement': requiresManualRoundIncrement,
    };
  }
}
