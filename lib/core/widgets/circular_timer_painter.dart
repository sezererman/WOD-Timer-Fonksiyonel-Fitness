import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Dairesel timer gösterimi için CustomPainter.
/// İlerleme yüzdesine göre bir halka çizer.
///
/// PERFORMANS: Paint nesneleri constructor'da bir kez oluşturulup
/// cache'leniyor. paint() saniyede 1 çağrıldığından allokasyonları
/// sıfırlamak GC pressure'ı tamamen ortadan kaldırır.
class CircularTimerPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  // Paint nesneleri: constructor'da TEK KEZ oluşturulur.
  // paint() her çağrıldığında yeniden alloke edilmez.
  late final Paint _bgPaint;
  late final Paint _progressPaint;
  late final Paint _glowPaint;

  CircularTimerPainter({
    required this.progress,
    required this.progressColor,
    this.backgroundColor = const Color(0xFF2A2A40),
    this.strokeWidth = 8.0,
  }) {
    _bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    _progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // PERFORMANS: MaskFilter.blur kaldırıldı.
    // Blur, GPU'da her paint() çağrısında ayrı bir render pass gerektirir.
    // Benzer görsel efekt: Geniş strokeWidth + düşük alpha ile soft hale.
    _glowPaint = Paint()
      ..color = progressColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 8
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Sıfır allokasyon — yalnızca hesaplama + draw call
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Arka plan halkası
    canvas.drawCircle(center, radius, _bgPaint);

    // İlerleme + glow yalnızca progress > 0 ise çizilir
    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress;
      final rect = Rect.fromCircle(center: center, radius: radius);
      const startAngle = -math.pi / 2;

      // Glow efekti
      canvas.drawArc(rect, startAngle, sweepAngle, false, _glowPaint);
      // Ana ilerleme
      canvas.drawArc(rect, startAngle, sweepAngle, false, _progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
