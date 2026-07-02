import 'package:equatable/equatable.dart';
import 'timer_phase.dart';

/// Düzleştirilmiş (flattened) ağacın her bir elemanını temsil eder.
/// TimerBloc sadece bu listeyi okur ve sırayla çalıştırır.
class TimerPhaseItem extends Equatable {
  /// Fazın türü (Hazırlık, Çalışma, Dinlenme, Soğuma)
  final TimerPhase phase;

  /// Bu spesifik fazın kaç saniye süreceği
  final int durationSeconds;

  /// Bu fazın ait olduğu tur (round) numarası. UI'da göstermek için.
  final int round;

  /// İsteğe bağlı etiket. Örneğin "5 dk AMRAP", "Isınma" vb.
  final String label;

  const TimerPhaseItem({
    required this.phase,
    required this.durationSeconds,
    required this.round,
    required this.label,
  });

  @override
  List<Object?> get props => [phase, durationSeconds, round, label];
}
