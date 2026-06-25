import '../../domain/entities/timer_sound_type.dart';
import '../../domain/repositories/audio_repository.dart';
import '../datasources/audio_service.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioService _audioService;

  AudioRepositoryImpl(this._audioService);

  @override
  Future<void> init() async {
    await _audioService.init();
  }

  @override
  Future<void> playSound(TimerSoundType type) async {
    await _audioService.playSound(type);
  }

  @override
  void setMuted(bool isMuted) {
    _audioService.setMuted(isMuted);
  }

  @override
  bool get isMuted => _audioService.isMuted;
}
