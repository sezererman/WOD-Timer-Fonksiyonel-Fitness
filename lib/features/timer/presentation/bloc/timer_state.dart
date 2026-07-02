import 'package:equatable/equatable.dart';
import '../../domain/entities/timer_config.dart';
import '../../domain/entities/timer_phase.dart';
import '../../domain/entities/timer_phase_item.dart';

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
  final List<TimerPhaseItem> phases;
  final int currentPhaseIndex;
  final int remainingSeconds;
  final TimerConfig config;

  const TimerActiveState({
    required this.phases,
    required this.currentPhaseIndex,
    required this.remainingSeconds,
    required this.config,
  });

  /// Güvenli getter: Index sınırları dışındaysa null dönmesini engeller
  TimerPhaseItem? get currentPhaseItem {
    if (currentPhaseIndex >= 0 && currentPhaseIndex < phases.length) {
      return phases[currentPhaseIndex];
    }
    return null;
  }

  // UI uyumluluğu için mevcut getter'lar (Legacy desteği)
  TimerPhase get phase => currentPhaseItem?.phase ?? TimerPhase.work;
  int get totalPhaseSeconds => currentPhaseItem?.durationSeconds ?? 0;
  int get currentRound => currentPhaseItem?.round ?? 1;
  int get totalRounds => phases.isEmpty ? 1 : phases.map((e) => e.round).reduce((a, b) => a > b ? a : b);
  String get phaseLabel => currentPhaseItem?.label ?? '';

  double get progress {
    if (totalPhaseSeconds == 0) return 0.0;
    return 1.0 - (remainingSeconds / totalPhaseSeconds);
  }

  @override
  List<Object?> get props => [
        phases,
        currentPhaseIndex,
        remainingSeconds,
        config,
      ];
}

/// Timer çalışıyor.
class TimerRunning extends TimerActiveState {
  const TimerRunning({
    required super.phases,
    required super.currentPhaseIndex,
    required super.remainingSeconds,
    required super.config,
  });
}

/// Timer duraklatıldı.
class TimerPausedState extends TimerActiveState {
  const TimerPausedState({
    required super.phases,
    required super.currentPhaseIndex,
    required super.remainingSeconds,
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
