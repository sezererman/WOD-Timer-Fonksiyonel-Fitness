import 'workout_block.dart';

/// Yaprak (Leaf) blok nesnesi. İçinde başka blok barındıramaz.
/// Yalnızca belirli bir çalışma (work) ve isteğe bağlı dinlenme (rest)
/// sürelerini tutar. Standart bir interval setini temsil eder.
class SingleIntervalBlock extends WorkoutBlock {
  /// Çalışma süresi (saniye).
  final int workSeconds;

  /// Çalışma sonrası dinlenme süresi (saniye). Varsayılan 0.
  final int restSeconds;

  /// Bu spesifik intervalden kaç tane yapılacağı (opsiyonel basit tekrar).
  /// Daha karmaşık tekrarlar ComplexSetBlock ile sağlanır, ancak 
  /// düz "3 tur 1 dk çalış 30 sn dinlen" için kolaylıktır.
  final int rounds;

  const SingleIntervalBlock({
    required super.id,
    super.name = 'Interval',
    required this.workSeconds,
    this.restSeconds = 0,
    this.rounds = 1,
  });

  /// Toplam süre: (Çalışma + Dinlenme) * Tur Sayısı.
  /// Not: Genellikle son turun dinlenmesi sayılmaz ancak basit hesaplama
  /// için burada dahil ediyoruz. UI tarafında 'phase' (faz) hesaplanırken
  /// son dinlenmeler kırpılabilir.
  @override
  int get totalDurationSeconds {
    final singleRoundDuration = workSeconds + restSeconds;
    // Eğer sadece 1 tursa veya hiç dinlenme yoksa direkt çarpım
    if (rounds <= 1) return singleRoundDuration * rounds;
    
    // Klasik mantık: Son turun dinlenmesi atlanabilir. 
    // Ancak WOD Builder esnekliğinde, her turun tam bitmesi istenebilir.
    // Şimdilik standart "son turda dinlenme yok" mantığı kuruyoruz:
    return (singleRoundDuration * rounds) - restSeconds;
  }

  /// Equatable props ile veri karşılaştırması
  @override
  List<Object?> get props => [id, name, workSeconds, restSeconds, rounds];
}
