import 'package:equatable/equatable.dart';
import 'workout_mode.dart';

/// Önceden tanımlı antrenman ayarları.
class WorkoutPreset extends Equatable {
  final String name;
  final WorkoutMode mode;
  final int rounds;
  final int workSeconds;
  final int restSeconds;
  final int prepareSeconds;

  const WorkoutPreset({
    required this.name,
    required this.mode,
    required this.rounds,
    required this.workSeconds,
    this.restSeconds = 0,
    this.prepareSeconds = 10,
  });

  @override
  List<Object?> get props => [name, mode, rounds, workSeconds, restSeconds];
}
