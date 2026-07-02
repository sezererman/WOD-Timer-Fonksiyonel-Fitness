import 'package:flutter/material.dart';

/// Uygulama renk paleti — CrossFit/Fitness temasına uygun
/// koyu ve enerji dolu renkler.
class AppColors {
  AppColors._();

  // Ana Renkler
  static const Color primary = Color(0xFFFF6B35);       // Turuncu — enerji
  static const Color primaryDark = Color(0xFFE55A2B);
  static const Color primaryLight = Color(0xFFFF8A5C);

  static const Color secondary = Color(0xFF00E5FF);      // Cyan — kontrast
  static const Color secondaryDark = Color(0xFF00B8D4);

  // Arka Plan
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color backgroundCard = Color(0xFF1A1A2E);
  static const Color backgroundElevated = Color(0xFF16213E);

  // Yüzey
  static const Color surface = Color(0xFF1E1E30);
  static const Color surfaceLight = Color(0xFF2A2A40);

  // Faz Renkleri
  static const Color workPhase = Color(0xFFE63946);      // WORK — Hırslı Kırmızı
  static const Color restPhase = Color(0xFF457B9D);      // REST — Dinlendirici Mavi
  static const Color preparePhase = Color(0xFFFFEB3B);    // PREPARE — sarı
  static const Color cooldownPhase = Color(0xFF42A5F5);   // COOLDOWN — mavi

  // Metin
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textHint = Color(0xFF6C6C80);

  // Durum
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFEB3B);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, backgroundCard],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceLight, surface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
