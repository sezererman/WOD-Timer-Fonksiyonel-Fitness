import 'package:equatable/equatable.dart';
import '../../domain/entities/timer_config.dart';

/// Timer Bloc event'leri.
abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

/// Timer'ı başlat.
class TimerStarted extends TimerEvent {
  final TimerConfig config;
  const TimerStarted(this.config);

  @override
  List<Object?> get props => [config];
}

/// Timer'ı duraklat.
class TimerPaused extends TimerEvent {
  const TimerPaused();
}

/// Timer'a devam et.
class TimerResumed extends TimerEvent {
  const TimerResumed();
}

/// Timer'ı sıfırla.
class TimerReset extends TimerEvent {
  const TimerReset();
}

/// Antrenmanı sonlandır.
class TimerWorkoutEnded extends TimerEvent {
  const TimerWorkoutEnded();
}

/// Her saniye tetiklenen dahili tick event'i.
class TimerTicked extends TimerEvent {
  final int elapsedSeconds;
  const TimerTicked(this.elapsedSeconds);

  @override
  List<Object?> get props => [elapsedSeconds];
}

/// AMRAP için manuel tur artırma.
class TimerRoundIncremented extends TimerEvent {
  const TimerRoundIncremented();
}

/// Timer'ı tamamen durdur ve iptal et.
class TimerStopped extends TimerEvent {
  const TimerStopped();
}

/// Uygulama arka plandan (paused) ön plana (resumed) döndüğünde
/// arka planda geçen süreyi telafi etmek için sayacı ileri sarar.
class TimerFastForwarded extends TimerEvent {
  final Duration elapsedBackgroundDuration;
  const TimerFastForwarded(this.elapsedBackgroundDuration);

  @override
  List<Object?> get props => [elapsedBackgroundDuration];
}
