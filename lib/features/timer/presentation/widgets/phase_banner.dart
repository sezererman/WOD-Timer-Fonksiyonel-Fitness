import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/timer_phase.dart';

/// Mevcut fazı gösteren banner (WORK / REST / PREPARE / COOLDOWN).
///
/// PERFORMANS: TextStyle nesneleri static Map'te cache'leniyor.
/// 4 olası TimerPhase değeri için ilk build'de oluşturulur,
/// sonraki her build'de aynı nesne döner — sıfır allokasyon.
class PhaseBanner extends StatelessWidget {
  final TimerPhase phase;

  const PhaseBanner({
    super.key,
    required this.phase,
  });

  // Phase renkleri — Map lookup O(1), nesne allokasyonu yok
  static const Map<TimerPhase, Color> _phaseColors = {
    TimerPhase.work:     AppColors.workPhase,
    TimerPhase.rest:     AppColors.restPhase,
    TimerPhase.prepare:  AppColors.preparePhase,
    TimerPhase.cooldown: AppColors.cooldownPhase,
  };

  static const Map<TimerPhase, String> _phaseTexts = {
    TimerPhase.work:     AppStrings.work,
    TimerPhase.rest:     AppStrings.rest,
    TimerPhase.prepare:  AppStrings.prepare,
    TimerPhase.cooldown: AppStrings.cooldown,
  };

  // TextStyle cache — phase başına tek nesne
  static final Map<TimerPhase, TextStyle> _styleCache = {};

  TextStyle _textStyle(TimerPhase p) {
    return _styleCache.putIfAbsent(p, () => TextStyle(
      fontFamily: 'Orbitron',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: _phaseColors[p]!,
      letterSpacing: 8,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final color = _phaseColors[phase]!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Text(
        _phaseTexts[phase]!,
        style: _textStyle(phase),
      ),
    );
  }
}
