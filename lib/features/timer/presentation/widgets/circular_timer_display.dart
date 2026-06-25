import 'dart:math';
import 'package:flutter/material.dart';

/// Yüksek performanslı ve pürüzsüz animasyonlu dairesel zamanlayıcı (Circular Timer)
/// 
/// [totalDuration]: Zamanlayıcının hedeflediği toplam süre.
/// [currentDuration]: Şu ana kadar geçen (veya kalan) süre.
/// [progressColor]: Dolum çemberinin neon rengi.
class CircularTimerDisplay extends StatefulWidget {
  final Duration totalDuration;
  final Duration currentDuration;
  final Color progressColor;

  const CircularTimerDisplay({
    super.key,
    required this.totalDuration,
    required this.currentDuration,
    required this.progressColor,
  });

  @override
  State<CircularTimerDisplay> createState() => _CircularTimerDisplayState();
}

class _CircularTimerDisplayState extends State<CircularTimerDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  double _oldProgress = 0.0;
  double _targetProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // BLoC'tan gelen verilerin saniye bazlı (1000ms) olduğunu varsayarak,
    // aradaki farkı yumuşatmak için 1 saniyelik bir animasyon süresi belirliyoruz.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _targetProgress = _calculateProgress(widget.currentDuration);
    _oldProgress = _targetProgress;

    _progressAnimation = Tween<double>(
      begin: _oldProgress,
      end: _targetProgress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  double _calculateProgress(Duration current) {
    if (widget.totalDuration.inMilliseconds == 0) return 0.0;
    // İlerlemeyi 0.0 ile 1.0 arasına sıkıştırıyoruz (clamp)
    return (current.inMilliseconds / widget.totalDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  @override
  void didUpdateWidget(covariant CircularTimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Yalnızca süre değiştiğinde animasyonu tetikliyoruz.
    if (oldWidget.currentDuration != widget.currentDuration ||
        oldWidget.totalDuration != widget.totalDuration) {
      
      // Animasyonun şu an nerede kaldığını alıp sıçrama (jump) olmasını engelliyoruz
      _oldProgress = _progressAnimation.value;
      _targetProgress = _calculateProgress(widget.currentDuration);
      
      // Geçen gerçek zaman farkını hesaplayarak, eğer süre birden zıplarsa (örn: 2 sn atlarsa)
      // animasyon hızını ona göre dinamik ayarlıyoruz.
      final int diffMs = (widget.currentDuration.inMilliseconds - 
                    oldWidget.currentDuration.inMilliseconds).abs();
      final int durationMs = diffMs > 0 ? diffMs : 1000;
      
      _controller.duration = Duration(milliseconds: durationMs);

      _progressAnimation = Tween<double>(
        begin: _oldProgress,
        end: _targetProgress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

      // Animasyonu baştan başlatıp yeni hedefe (1 saniye içinde) akmasını sağlıyoruz.
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    // Saat formatı da gerekebileceği için opsiyonel olarak ekleniyor.
    if (duration.inHours > 0) {
      final hours = twoDigits(duration.inHours);
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // OPTİMİZASYON 1: RepaintBoundary
    // Bu sayede çember saniyede 60-120 kez yeniden çizilirken (paint), 
    // sayfanın (veya üstteki diğer widget'ların) render ağacını kirletmez,
    // çizim işlemlerini ayrı bir katmanda (layer) izole eder.
    return RepaintBoundary(
      // OPTİMİZASYON 2: AnimatedBuilder kullanımı
      // SetState kullanmak yerine AnimatedBuilder ile sadece _CircularTimerPainter
      // class'ını saniyede 60 FPS yeniden build/paint ediyoruz.
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularTimerPainter(
              progress: _progressAnimation.value,
              progressColor: widget.progressColor,
              trackColor: Colors.grey[850]!, // Koyu mat gri iz (Dark Theme)
            ),
            // OPTİMİZASYON 3: Text widget'ını `child` olarak AnimatedBuilder'a geçiyoruz.
            // Text widget'ı 60 kere YENİDEN OLUŞTURULMAZ! Yalnızca didUpdateWidget (saniyede 1)
            // çalıştığında yeni state ile 1 kere oluşturulur ve bellekte tutularak boyamaya eklenir.
            child: child,
          );
        },
        child: Center(
          // Monospaced (sabit genişlikte) büyük, rahat okunan dijital zamanlayıcı metni
          child: Text(
            _formatDuration(widget.currentDuration),
            style: const TextStyle(
              fontSize: 64.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              // Fontu sistemdeki sabit genişlikli fonta zorluyoruz
              // Ayrıca TabularFigures sayesinde rakamlar genişleyip daralarak zıplama yapmaz.
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color trackColor;

  _CircularTimerPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Çizgi kalınlıklarından dolayı taşma (clipping) olmaması için yarıçapı biraz daraltıyoruz.
    final radius = min(size.width / 2, size.height / 2) - 24.0;

    // 1. Zemin Çemberi (Koyu Mat Gri İz)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Neon Glow Efekti (Arka planda bulanık, biraz daha kalın, parlamayı sağlayan çizim)
    final glowPaint = Paint()
      ..color = progressColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0); // Işık saçılım efekti

    // 3. Ana Dolum Çemberi (Parlak ve Katı Çizgi)
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -pi / 2; // Saat 12 yönünden (üstten) başlaması için -90 derece.
    final sweepAngle = 2 * pi * progress; // İlerlemeyi 360 dereceye oranlıyoruz.

    // Dolum açısı (sweepAngle) > 0 ise neon efektini ve dolumu çiziyoruz.
    if (sweepAngle > 0) {
      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter oldDelegate) {
    // Gereksiz paint işlemlerini önlüyoruz. Yalnızca değerler değiştiğinde CustomPaint kendini tazeler.
    return oldDelegate.progress != progress ||
           oldDelegate.progressColor != progressColor ||
           oldDelegate.trackColor != trackColor;
  }
}
