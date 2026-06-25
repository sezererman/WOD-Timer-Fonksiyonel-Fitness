import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/circular_timer_painter.dart';
import '../../domain/entities/timer_phase.dart';

/// Büyük dairesel timer gösterimi.
///
/// PERFORMANS: TextStyle + Shadow nesneleri static cache'te saklanıyor.
/// Saniyede bir çağrılan build() artık yeni nesne alloke etmiyor.
class TimerDisplay extends StatelessWidget {
  final int remainingSeconds;
  final int totalPhaseSeconds;
  final TimerPhase phase;
  final double progress;

  const TimerDisplay({
    super.key,
    required this.remainingSeconds,
    required this.totalPhaseSeconds,
    required this.phase,
    required this.progress,
  });

  // Phase renkleri sabit — Map lookup O(1), nesne allokasyonu yok
  static const Map<TimerPhase, Color> _phaseColors = {
    TimerPhase.work:     AppColors.workPhase,
    TimerPhase.rest:     AppColors.restPhase,
    TimerPhase.prepare:  AppColors.preparePhase,
    TimerPhase.cooldown: AppColors.cooldownPhase,
  };

  // TextStyle'lar yalnızca phase değişince (4 olası değer) oluşturulur.
  // Saniyede bir rebuild'de aynı nesne döner — sıfır allokasyon.
  static final Map<TimerPhase, TextStyle> _styleCache = {};

  TextStyle _textStyle(TimerPhase p) {
    return _styleCache.putIfAbsent(p, () {
      final color = _phaseColors[p]!;
      return TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 96,
        height: 1.0,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 4,
        fontFeatures: const [ui.FontFeature.tabularFigures()],
        shadows: [
          Shadow(color: color.withValues(alpha: 0.5), blurRadius: 20),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dairesel ilerleme halkası — ayrı repaint layer
          RepaintBoundary(
            child: SizedBox(
              width: 320,
              height: 320,
              child: CustomPaint(
                painter: CircularTimerPainter(
                  progress: progress,
                  progressColor: _phaseColors[phase]!,
                  strokeWidth: 10,
                ),
              ),
            ),
          ),
          // Süre metni — cached TextStyle
          SizedBox(
            width: 320,
            height: 120,
            child: Center(
              child: Text(
                DurationFormatter.format(remainingSeconds),
                style: _textStyle(phase),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
