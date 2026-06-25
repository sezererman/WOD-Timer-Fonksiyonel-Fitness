import 'package:equatable/equatable.dart';
import '../../domain/entities/workout_mode.dart';
import '../../domain/entities/workout_preset.dart';

abstract class WorkoutModeState extends Equatable {
  const WorkoutModeState();
  @override
  List<Object?> get props => [];
}

class WorkoutModeInitial extends WorkoutModeState {
  const WorkoutModeInitial();
}

class WorkoutModeLoaded extends WorkoutModeState {
  final List<WorkoutMode> modes;
  final WorkoutMode? selectedMode;
  final List<WorkoutPreset> presets;

  const WorkoutModeLoaded({
    required this.modes,
    this.selectedMode,
    this.presets = const [],
  });

  @override
  List<Object?> get props => [modes, selectedMode, presets];
}
