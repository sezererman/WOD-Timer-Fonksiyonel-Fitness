import '../entities/timer_sound_type.dart';

abstract class AudioRepository {
  /// Initializes the audio engine, configures context, and preloads sounds.
  Future<void> init();

  /// Plays the specified timer sound type.
  Future<void> playSound(TimerSoundType type);

  /// Sets whether the sounds are muted or not.
  void setMuted(bool isMuted);

  /// Returns whether the sounds are currently muted.
  bool get isMuted;
}
