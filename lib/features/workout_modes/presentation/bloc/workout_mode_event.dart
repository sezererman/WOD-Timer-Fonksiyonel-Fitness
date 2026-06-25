import 'package:equatable/equatable.dart';
import '../../domain/entities/workout_mode.dart';
import '../../domain/entities/workout_preset.dart';

abstract class WorkoutModeEvent extends Equatable {
  const WorkoutModeEvent();
  @override
  List<Object?> get props => [];
}

class WorkoutModesLoaded extends WorkoutModeEvent {
  const WorkoutModesLoaded();
}

class WorkoutModeSelected extends WorkoutModeEvent {
  final WorkoutMode mode;
  const WorkoutModeSelected(this.mode);
  @override
  List<Object?> get props => [mode];
}

class WorkoutPresetSaved extends WorkoutModeEvent {
  final WorkoutPreset preset;
  const WorkoutPresetSaved(this.preset);
  @override
  List<Object?> get props => [preset];
}
