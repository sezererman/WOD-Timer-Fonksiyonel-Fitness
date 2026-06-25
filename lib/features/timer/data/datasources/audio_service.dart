import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/timer_sound_type.dart';

/// Preloads and manages the audio players for the CrossFit Timer.
/// Ensures sounds are mixed correctly without stopping background music.
class AudioService {
  final AudioPlayer _beepShortPlayer = AudioPlayer();
  final AudioPlayer _startBellPlayer = AudioPlayer();
  final AudioPlayer _halfwayGongPlayer = AudioPlayer();
  final AudioPlayer _finishHornPlayer = AudioPlayer();

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
        _startBellPlayer.setAudioContext(context),
        _halfwayGongPlayer.setAudioContext(context),
        _finishHornPlayer.setAudioContext(context),
      ]);

      // Preload specific files
      await Future.wait([
        _beepShortPlayer.setSource(AssetSource('sounds/beep_short.mp3')),
        _startBellPlayer.setSource(AssetSource('sounds/start_bell.mp3')),
        _halfwayGongPlayer.setSource(AssetSource('sounds/halfway_gong.mp3')),
        _finishHornPlayer.setSource(AssetSource('sounds/finish_horn.mp3')),
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
          await _safePlay(_startBellPlayer);
          break;
        case TimerSoundType.halfwayGong:
          await _safePlay(_halfwayGongPlayer);
          break;
        case TimerSoundType.finishHorn:
          await _safePlay(_finishHornPlayer);
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
      _startBellPlayer.dispose(),
      _halfwayGongPlayer.dispose(),
      _finishHornPlayer.dispose(),
    ]);
  }
}
