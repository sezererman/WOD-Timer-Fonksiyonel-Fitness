import 'package:equatable/equatable.dart';
import '../../../workout_modes/domain/entities/workout_mode.dart';
import 'blocks/workout_block.dart';

/// Timer yapılandırma entity'si.
/// Bir antrenmanın tüm zamanlama parametrelerini tutar.
class TimerConfig extends Equatable {
  /// Özel antrenman oluşturucu (Custom WOD Builder) ağaç yapısı.
  /// Eğer bu liste boş değilse, alt taraftaki 'Legacy' alanlar yerine
  /// bu hiyerarşik yapı (ağaç) kullanılarak antrenman akışı oluşturulur.
  final List<WorkoutBlock> blocks;

  // --- LEGACY ALANLAR ---
  // İleride UI ve Bloc tamamen 'blocks' yapısına geçtiğinde bu alanlar
  // kaldırılabilecek veya sadece 'Basit Mod' için korunacaktır.

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
    this.blocks = const [],
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
    // 1. Yeni Sistem: Eğer özel bloklar tanımlandıysa ağaçtan hesapla
    if (blocks.isNotEmpty) {
      final blocksDuration = blocks.fold<int>(
        0,
        (sum, block) => sum + block.totalDurationSeconds,
      );
      return prepareSeconds + blocksDuration + cooldownSeconds;
    }

    // 2. Eski Sistem (Legacy): Düz hesaplama
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
    List<WorkoutBlock>? blocks,
    int? rounds,
    int? workSeconds,
    int? restSeconds,
    int? prepareSeconds,
    int? cooldownSeconds,
    WorkoutMode? mode,
    bool? requiresManualRoundIncrement,
  }) {
    return TimerConfig(
      blocks: blocks ?? this.blocks,
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
        blocks,
        rounds,
        workSeconds,
        restSeconds,
        prepareSeconds,
        cooldownSeconds,
        mode,
        requiresManualRoundIncrement,
      ];
}

