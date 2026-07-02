import 'workout_block.dart';

/// Dal (Branch/Composite) blok nesnesi. 
/// Kendi içinde başka [WorkoutBlock] listesi barındırır.
/// İçindeki bloklar [SingleIntervalBlock] olabileceği gibi 
/// başka [ComplexSetBlock] nesneleri de olabilir (Sonsuz derinlik).
class ComplexSetBlock extends WorkoutBlock {
  /// Bu kompleks yapının alt parçaları.
  final List<WorkoutBlock> blocks;

  /// İçindeki [blocks] listesinin sırayla kaç defa tekrarlanacağı.
  final int repetitions;

  /// Her tam döngü (bütün alt blokların bitimi) arasındaki dinlenme süresi.
  final int restBetweenRepetitions;

  const ComplexSetBlock({
    required super.id,
    required super.name,
    required this.blocks,
    this.repetitions = 1,
    this.restBetweenRepetitions = 0,
  });

  /// Toplam süreyi rekürsif olarak hesaplar.
  @override
  int get totalDurationSeconds {
    if (blocks.isEmpty || repetitions <= 0) return 0;

    // Tek bir turun toplam süresi (alt blokların süreleri toplanır)
    final singleRepDuration = blocks.fold<int>(
      0,
      (sum, block) => sum + block.totalDurationSeconds,
    );

    // Tekrar arası dinlenmeler (Son tekrarda dinlenme olmaz)
    final totalRestTime = restBetweenRepetitions * (repetitions - 1);

    return (singleRepDuration * repetitions) + totalRestTime;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        blocks,
        repetitions,
        restBetweenRepetitions,
      ];
}
