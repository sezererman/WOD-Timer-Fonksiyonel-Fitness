import 'package:equatable/equatable.dart';
import '../../../workout_modes/domain/entities/workout_mode.dart';

/// Timer yapılandırma entity'si.
/// Bir antrenmanın tüm zamanlama parametrelerini tutar.
class TimerConfig extends Equatable {
  /// Toplam tur sayısı.
  final int rounds;

  /// Çalışma süresi (saniye).
  final int workSeconds;

  /// Dinlenme süresi (saniye).
  final int restSeconds;

  /// Hazırlık süresi (saniye).
  final int prepareSeconds;

  /// Soğuma süresi (saniye).
  final int cooldownSeconds;

  /// Antrenman modu.
  final WorkoutMode? mode;

  /// Modun manuel tur artışı gerektirip gerektirmediği (ör: AMRAP).
  final bool requiresManualRoundIncrement;

  const TimerConfig({
    required this.rounds,
    required this.workSeconds,
    this.restSeconds = 0,
    this.prepareSeconds = 10,
    this.cooldownSeconds = 0,
    this.mode,
    this.requiresManualRoundIncrement = false,
  });

  /// Toplam antrenman süresi (saniye).
  int get totalSeconds {
    final effectiveRounds = rounds > 0 ? rounds : 1;
    // AMRAP modunda rounds 0 veya 1 olduğunda aralara dinlenme konulmaz.
    final restCount = effectiveRounds > 1 ? effectiveRounds - 1 : 0;
    return prepareSeconds +
        (workSeconds * effectiveRounds) +
        (restSeconds * restCount) +
        cooldownSeconds;
  }

  /// Modun görünen adını döndürür (Law of Demeter düzeltmesi).
  String get modeDisplayName => mode?.displayName ?? WorkoutMode.custom.displayName;

  TimerConfig copyWith({
    int? rounds,
    int? workSeconds,
    int? restSeconds,
    int? prepareSeconds,
    int? cooldownSeconds,
    WorkoutMode? mode,
    bool? requiresManualRoundIncrement,
  }) {
    return TimerConfig(
      rounds: rounds ?? this.rounds,
      workSeconds: workSeconds ?? this.workSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      prepareSeconds: prepareSeconds ?? this.prepareSeconds,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      mode: mode ?? this.mode,
      requiresManualRoundIncrement:
          requiresManualRoundIncrement ?? this.requiresManualRoundIncrement,
    );
  }

  @override
  List<Object?> get props => [
        rounds,
        workSeconds,
        restSeconds,
        prepareSeconds,
        cooldownSeconds,
        mode,
        requiresManualRoundIncrement,
      ];
}
