import 'package:equatable/equatable.dart';
import 'workout_mode.dart';
import '../../../timer/domain/entities/timer_config.dart';

/// Tüm antrenman modları için temel sınıf.
abstract class WorkoutConfig extends Equatable {
  final String id;
  final String name;
  final int prepareSeconds;
  final WorkoutMode mode;

  const WorkoutConfig({
    required this.id,
    required this.name,
    required this.mode,
    this.prepareSeconds = 10,
  });

  /// Bu yapılandırmayı Timer'ın anlayacağı genel formata dönüştürür (Adapter Pattern).
  TimerConfig toTimerConfig();

  /// Modun manuel tur artışı (ör: AMRAP'te tur ekleme butonu) gerektirip gerektirmediği.
  bool get requiresManualRoundIncrement => false;

  @override
  List<Object?> get props => [id, name, prepareSeconds, mode];
}

/// AMRAP (As Many Rounds As Possible)
/// Belirlenen toplam süre içinde mümkün olduğunca çok tur yapmayı hedefler.
class AmrapConfig extends WorkoutConfig {
  final int totalSeconds;

  const AmrapConfig({
    required super.id,
    required super.name,
    required this.totalSeconds,
    super.prepareSeconds,
  }) : super(mode: WorkoutMode.amrap);

  @override
  TimerConfig toTimerConfig() => TimerConfig(
        rounds: 1, // AMRAP genelde tek bir büyük turdur
        workSeconds: totalSeconds,
        prepareSeconds: prepareSeconds,
        mode: mode,
        requiresManualRoundIncrement: requiresManualRoundIncrement,
      );

  @override
  bool get requiresManualRoundIncrement => true;

  @override
  List<Object?> get props => [...super.props, totalSeconds];
}

/// FOR TIME
/// Belirlenen tur sayısını en kısa sürede bitirmeyi hedefler.
class ForTimeConfig extends WorkoutConfig {
  final int rounds;
  final int? timeCapSeconds;

  const ForTimeConfig({
    required super.id,
    required super.name,
    required this.rounds,
    this.timeCapSeconds,
    super.prepareSeconds,
  }) : super(mode: WorkoutMode.forTime);

  @override
  TimerConfig toTimerConfig() => TimerConfig(
        rounds: rounds,
        workSeconds: 0, // For Time'da her tur belirsiz sürebilir, Time Cap kullanılır
        prepareSeconds: prepareSeconds,
        mode: mode,
        requiresManualRoundIncrement: requiresManualRoundIncrement,
      );

  @override
  List<Object?> get props => [...super.props, rounds, timeCapSeconds];
}

/// EMOM (Every Minute on the Minute)
/// Her dakikanın (veya belirlenen aralığın) başında yeni bir tura başlanır.
class EmomConfig extends WorkoutConfig {
  final int intervalSeconds;
  final int totalRounds;

  const EmomConfig({
    required super.id,
    required super.name,
    required this.totalRounds,
    this.intervalSeconds = 60,
    super.prepareSeconds,
  }) : super(mode: WorkoutMode.emom);

  @override
  TimerConfig toTimerConfig() => TimerConfig(
        rounds: totalRounds,
        workSeconds: intervalSeconds,
        prepareSeconds: prepareSeconds,
        mode: mode,
        requiresManualRoundIncrement: requiresManualRoundIncrement,
      );

  @override
  List<Object?> get props => [...super.props, intervalSeconds, totalRounds];
}

/// TABATA
/// Klasik 20sn çalışma / 10sn dinlenme yapısı veya özel versiyonları.
class TabataConfig extends WorkoutConfig {
  final int rounds;
  final int workSeconds;
  final int restSeconds;

  const TabataConfig({
    required super.id,
    required super.name,
    required this.rounds,
    this.workSeconds = 20,
    this.restSeconds = 10,
    super.prepareSeconds,
  }) : super(mode: WorkoutMode.tabata);

  @override
  TimerConfig toTimerConfig() => TimerConfig(
        rounds: rounds,
        workSeconds: workSeconds,
        restSeconds: restSeconds,
        prepareSeconds: prepareSeconds,
        mode: mode,
        requiresManualRoundIncrement: requiresManualRoundIncrement,
      );

  @override
  List<Object?> get props => [...super.props, rounds, workSeconds, restSeconds];
}

/// Yeni antrenman modları eklemeyi kolaylaştıran Factory sınıfı (Factory Pattern).
class WorkoutFactory {
  static WorkoutConfig createDefault(WorkoutMode mode) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    switch (mode) {
      case WorkoutMode.amrap:
        return AmrapConfig(id: id, name: 'AMRAP', totalSeconds: 600); // 10 dk
      case WorkoutMode.emom:
        return EmomConfig(id: id, name: 'EMOM', totalRounds: 10);
      case WorkoutMode.tabata:
        return TabataConfig(id: id, name: 'TABATA', rounds: 8);
      case WorkoutMode.forTime:
        return ForTimeConfig(id: id, name: 'FOR TIME', rounds: 5);
      case WorkoutMode.custom:
        return TabataConfig(id: id, name: 'CUSTOM', rounds: 5, workSeconds: 60, restSeconds: 30);
    }
  }
}
