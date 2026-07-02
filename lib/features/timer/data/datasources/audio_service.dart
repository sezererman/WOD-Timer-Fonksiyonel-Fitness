import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/timer_sound_type.dart';
import '../../../../design_system/constants/asset_paths.dart';

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
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.alarm, // Sessiz/Titreşim modunu ezer
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
        iOS: AudioContextIOS(
          // AVAudioSessionCategory.playback zaten varsayılandır (Sessiz anahtarını ezer)
          options: const {
            AVAudioSessionOptions.duckOthers,
            AVAudioSessionOptions.mixWithOthers, // Arka plan müziğini durdurmaz
          },
        ),
      );

      await Future.wait([
        _beepShortPlayer.setAudioContext(context),
        _beepLongPlayer.setAudioContext(context),
        _roundCompletePlayer.setAudioContext(context),
        _workoutCompletePlayer.setAudioContext(context),
      ]);

      // Pre-warm (cache) the sources
      await Future.wait([
        _beepShortPlayer.setSource(AssetSource(AssetPaths.beepShort)),
        _beepLongPlayer.setSource(AssetSource(AssetPaths.beepLong)),
        _roundCompletePlayer.setSource(AssetSource(AssetPaths.roundComplete)),
        _workoutCompletePlayer.setSource(
          AssetSource(AssetPaths.workoutComplete),
        ),
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
          await _beepShortPlayer.play(AssetSource(AssetPaths.beepShort));
          break;
        case TimerSoundType.startBell:
          await _beepLongPlayer.play(AssetSource(AssetPaths.beepLong));
          break;
        case TimerSoundType.halfwayGong:
          await _roundCompletePlayer.play(
            AssetSource(AssetPaths.roundComplete),
          );
          break;
        case TimerSoundType.finishHorn:
          await _workoutCompletePlayer.play(
            AssetSource(AssetPaths.workoutComplete),
          );
          break;
      }
    } catch (e) {
      debugPrint('Failed to play sound $type: $e');
    }
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
