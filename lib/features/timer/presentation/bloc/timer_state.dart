import 'package:equatable/equatable.dart';
import '../../domain/entities/timer_config.dart';
import '../../domain/entities/timer_phase.dart';

/// Timer Bloc state'leri.
abstract class TimerState extends Equatable {
  const TimerState();

  @override
  List<Object?> get props => [];
}

/// Başlangıç durumu — timer henüz başlamadı.
class TimerInitial extends TimerState {
  const TimerInitial();
}

/// Çalışan ve duraklatılan durumlar için ortak base state (DRY & SRP için)
abstract class TimerActiveState extends TimerState {
  final TimerPhase phase;
  final int remainingSeconds;
  final int totalPhaseSeconds;
  final int currentRound;
  final int totalRounds;
  final TimerConfig config;

  const TimerActiveState({
    required this.phase,
    required this.remainingSeconds,
    required this.totalPhaseSeconds,
    required this.currentRound,
    required this.totalRounds,
    required this.config,
  });

  double get progress {
    if (totalPhaseSeconds == 0) return 0.0;
    return 1.0 - (remainingSeconds / totalPhaseSeconds);
  }

  @override
  List<Object?> get props => [
        phase,
        remainingSeconds,
        totalPhaseSeconds,
        currentRound,
        totalRounds,
        config,
      ];
}

/// Timer çalışıyor.
class TimerRunning extends TimerActiveState {
  const TimerRunning({
    required super.phase,
    required super.remainingSeconds,
    required super.totalPhaseSeconds,
    required super.currentRound,
    required super.totalRounds,
    required super.config,
  });
}

/// Timer duraklatıldı.
class TimerPausedState extends TimerActiveState {
  const TimerPausedState({
    required super.phase,
    required super.remainingSeconds,
    required super.totalPhaseSeconds,
    required super.currentRound,
    required super.totalRounds,
    required super.config,
  });
}

/// Timer tamamlandı.
class TimerCompleted extends TimerState {
  final TimerConfig config;
  final int totalElapsedSeconds;

  const TimerCompleted({
    required this.config,
    required this.totalElapsedSeconds,
  });

  @override
  List<Object?> get props => [config, totalElapsedSeconds];
}

/// Timer iptal edildi (kullanıcı tarafından durduruldu).
class TimerAborted extends TimerState {
  const TimerAborted();
}
