import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc({required SettingsRepository repository})
      : _repository = repository,
        super(const SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoad);
    on<SettingsUpdated>(_onUpdate);
  }

  Future<void> _onLoad(SettingsLoadRequested event, Emitter<SettingsState> emit) async {
    final settings = await _repository.getSettings();
    emit(SettingsLoaded(settings));
  }

  Future<void> _onUpdate(SettingsUpdated event, Emitter<SettingsState> emit) async {
    await _repository.updateSettings(event.settings);
    emit(SettingsLoaded(event.settings));
  }
}
