import '../entities/timer_sound_type.dart';
import '../repositories/audio_repository.dart';

class PlayTimerSoundUseCase {
  final AudioRepository _repository;

  PlayTimerSoundUseCase(this._repository);

  Future<void> call(TimerSoundType type) async {
    return _repository.playSound(type);
  }
}
