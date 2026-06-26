import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/timer_sound_type.dart';

/// Preloads and manages the audio players for the CrossFit Timer.
/// Ensures sounds are mixed correctly without stopping background music.
class AudioService {
  final AudioPlayer _beepShortPlayer = AudioPlayer();
  final AudioPlayer _beepLongPlayer = AudioPlayer();
  final AudioPlayer _roundCompletePlayer = AudioPlayer();
  final AudioPlayer _workoutCompletePlayer = AudioPlayer();

  bool _isMuted = false;

  bool get isMuted => _isMuted;

  void setMuted(bool isMuted) {
    _isMuted = isMuted;
  }

  /// Initializes the AudioContext and preloads the specific sound files.
  Future<void> init() async {
    try {
      final context = AudioContext(
        android: const AudioContextAndroid(
          usageType: AndroidUsageType.alarm,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
        iOS: AudioContextIOS(
          options: const {AVAudioSessionOptions.duckOthers},
        ),
      );

      await Future.wait([
        _beepShortPlayer.setAudioContext(context),
        _beepLongPlayer.setAudioContext(context),
        _roundCompletePlayer.setAudioContext(context),
        _workoutCompletePlayer.setAudioContext(context),
      ]);

      // Preload specific files
      await Future.wait([
        _beepShortPlayer.setSource(AssetSource('sounds/beep_short.wav')),
        _beepLongPlayer.setSource(AssetSource('sounds/beep_long.wav')),
        _roundCompletePlayer.setSource(AssetSource('sounds/round_complete.wav')),
        _workoutCompletePlayer.setSource(AssetSource('sounds/workout_complete.wav')),
      ]);
    } catch (e) {
      debugPrint('AudioService init failed: $e');
    }
  }

  /// Plays the requested sound without stopping background music.
  Future<void> playSound(TimerSoundType type) async {
    if (_isMuted) return;

    try {
      switch (type) {
        case TimerSoundType.beepShort:
          await _safePlay(_beepShortPlayer);
          break;
        case TimerSoundType.startBell:
          await _safePlay(_beepLongPlayer);
          break;
        case TimerSoundType.halfwayGong:
          await _safePlay(_roundCompletePlayer);
          break;
        case TimerSoundType.finishHorn:
          await _safePlay(_workoutCompletePlayer);
          break;
      }
    } catch (e) {
      debugPrint('Failed to play sound $type: $e');
    }
  }

  Future<void> _safePlay(AudioPlayer player) async {
    await player.stop();
    await player.resume();
  }

  Future<void> dispose() async {
    await Future.wait([
      _beepShortPlayer.dispose(),
      _beepLongPlayer.dispose(),
      _roundCompletePlayer.dispose(),
      _workoutCompletePlayer.dispose(),
    ]);
  }
}
