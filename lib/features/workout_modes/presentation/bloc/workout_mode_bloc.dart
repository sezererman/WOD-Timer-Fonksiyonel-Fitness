import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/workout_mode_repository.dart';
import 'workout_mode_event.dart';
import 'workout_mode_state.dart';

class WorkoutModeBloc extends Bloc<WorkoutModeEvent, WorkoutModeState> {
  final WorkoutModeRepository _repository;

  WorkoutModeBloc({required WorkoutModeRepository repository})
      : _repository = repository,
        super(const WorkoutModeInitial()) {
    on<WorkoutModesLoaded>(_onLoaded);
    on<WorkoutModeSelected>(_onSelected);
    on<WorkoutPresetSaved>(_onPresetSaved);
  }

  void _onLoaded(WorkoutModesLoaded event, Emitter<WorkoutModeState> emit) {
    final modes = _repository.getAvailableModes();
    emit(WorkoutModeLoaded(modes: modes));
  }

  void _onSelected(WorkoutModeSelected event, Emitter<WorkoutModeState> emit) {
    final modes = _repository.getAvailableModes();
    final presets = _repository.getPresetsForMode(event.mode);
    emit(WorkoutModeLoaded(
      modes: modes,
      selectedMode: event.mode,
      presets: presets,
    ));
  }

  Future<void> _onPresetSaved(
      WorkoutPresetSaved event, Emitter<WorkoutModeState> emit) async {
    await _repository.savePreset(event.preset);
  }
}
