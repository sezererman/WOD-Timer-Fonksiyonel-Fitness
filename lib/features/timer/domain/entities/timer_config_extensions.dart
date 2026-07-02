import 'timer_config.dart';
import 'timer_phase.dart';
import 'timer_phase_item.dart';
import 'blocks/workout_block.dart';
import 'blocks/single_interval_block.dart';
import 'blocks/complex_set_block.dart';

/// TimerConfig'i doğrusal bir TimerPhaseItem listesine çeviren extension.
extension TimerConfigPhaseGenerator on TimerConfig {
  /// Antrenman ağacını (veyahut eski 'legacy' sistemi) baştan sona
  /// düzleştirerek (flatten) [TimerPhaseItem] dizisine çevirir.
  List<TimerPhaseItem> generatePhases() {
    final List<TimerPhaseItem> phases = [];

    // 1. Hazırlık (Her iki sistemde de ortak)
    if (prepareSeconds > 0) {
      phases.add(TimerPhaseItem(
        phase: TimerPhase.prepare,
        durationSeconds: prepareSeconds,
        round: 1,
        label: 'Hazırlık',
      ));
    }

    if (blocks.isNotEmpty) {
      // YENİ SİSTEM: WorkoutBlock Ağacını çözümle
      _flattenBlocks(blocks, phases, 1, '');
    } else {
      // ESKİ SİSTEM: Legacy alanlardan (rounds, workSeconds vb.) çözümle
      _generateLegacyPhases(phases);
    }

    // 3. Soğuma (Her iki sistemde de ortak)
    if (cooldownSeconds > 0) {
      phases.add(TimerPhaseItem(
        phase: TimerPhase.cooldown,
        durationSeconds: cooldownSeconds,
        round: blocks.isNotEmpty ? 1 : rounds, // Ağaç sisteminde round konsepti farklı olabilir
        label: 'Soğuma',
      ));
    }

    return phases;
  }

  /// Yeni sistem (Custom WOD Builder) ağacını özyineli (recursive) olarak açar.
  int _flattenBlocks(
    List<WorkoutBlock> blockList,
    List<TimerPhaseItem> phases,
    int currentGlobalRound,
    String parentLabel,
  ) {
    int currentRound = currentGlobalRound;

    for (final block in blockList) {
      final blockLabel = parentLabel.isNotEmpty ? '$parentLabel - ${block.name}' : block.name;

      if (block is SingleIntervalBlock) {
        for (int r = 1; r <= block.rounds; r++) {
          final isLastRound = (r == block.rounds);

          // Çalışma Fazı
          if (block.workSeconds > 0) {
            phases.add(TimerPhaseItem(
              phase: TimerPhase.work,
              durationSeconds: block.workSeconds,
              round: currentRound,
              label: blockLabel,
            ));
          }

          // Dinlenme Fazı
          // Not: Varsayılan olarak son turda interval dinlenmesi atlanır
          // (Eğer hemen arkasından başka set geliyorsa o ayriyeten hesaba katılır)
          if (!isLastRound && block.restSeconds > 0) {
            phases.add(TimerPhaseItem(
              phase: TimerPhase.rest,
              durationSeconds: block.restSeconds,
              round: currentRound,
              label: blockLabel,
            ));
          }
          currentRound++;
        }
      } else if (block is ComplexSetBlock) {
        for (int rep = 1; rep <= block.repetitions; rep++) {
          final isLastRep = (rep == block.repetitions);
          final repLabel = '$blockLabel (Set $rep/${block.repetitions})';

          // Alt blokları çözümle
          currentRound = _flattenBlocks(block.blocks, phases, currentRound, repLabel);

          // Tekrar arası dinlenme
          if (!isLastRep && block.restBetweenRepetitions > 0) {
            phases.add(TimerPhaseItem(
              phase: TimerPhase.rest,
              durationSeconds: block.restBetweenRepetitions,
              round: currentRound - 1,
              label: 'Dinlenme ($blockLabel)',
            ));
          }
        }
      }
    }
    return currentRound;
  }

  /// Eski sistemi (AMRAP, EMOM, Tabata standart ayarları) düz bir listeye çevirir.
  void _generateLegacyPhases(List<TimerPhaseItem> phases) {
    final int effectiveRounds = rounds > 0 ? rounds : 1;
    final String label = modeDisplayName;

    for (int r = 1; r <= effectiveRounds; r++) {
      if (workSeconds > 0) {
        phases.add(TimerPhaseItem(
          phase: TimerPhase.work,
          durationSeconds: workSeconds,
          round: r,
          label: label,
        ));
      }

      final isLastRound = (r == effectiveRounds);
      
      // AMRAP modunda rounds 0 veya 1 olduğunda aralara dinlenme konulmaz mantığı
      // Legacy TimerConfig.totalSeconds içinde vardı.
      if (!isLastRound && restSeconds > 0) {
        phases.add(TimerPhaseItem(
          phase: TimerPhase.rest,
          durationSeconds: restSeconds,
          round: r,
          label: 'Dinlenme',
        ));
      }
    }
  }
}
