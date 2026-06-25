import 'package:flutter/material.dart';

// =============================================================================
// LevelBadge — Seviye Aralığı → Görsel Kimlik Eşlemesi
//
// Saf bir enum + extension çifti. Hiçbir widget bağımlılığı yoktur;
// domain/presentation her iki katmanda da kullanılabilir.
//
// Kullanım:
//   final badge = LevelBadge.fromLevel(currentLevel);
//   badge.color   // Color
//   badge.icon    // IconData
//   badge.label   // String ("Rookie", "Elite" vb.)
//   badge.tier    // int (1-5 arası sıra numarası)
// =============================================================================

/// CrossFit seviye kademeleri.
enum LevelBadge {
  rookie,       // Seviye 1-5
  beginner,     // Seviye 6-15
  intermediate, // Seviye 16-35
  advanced,     // Seviye 36-60
  elite,        // Seviye 61+
}

extension LevelBadgeX on LevelBadge {
  // ─── Temel Özellikler ──────────────────────────────────────────────────────

  /// Kullanıcıya gösterilen kademe adı.
  String get label => switch (this) {
        LevelBadge.rookie       => 'Rookie',
        LevelBadge.beginner     => 'Beginner',
        LevelBadge.intermediate => 'Intermediate',
        LevelBadge.advanced     => 'Advanced',
        LevelBadge.elite        => 'Elite',
      };

  /// Kademenin birden beşe sıra numarası (tooltip / karşılaştırma için).
  int get tier => switch (this) {
        LevelBadge.rookie       => 1,
        LevelBadge.beginner     => 2,
        LevelBadge.intermediate => 3,
        LevelBadge.advanced     => 4,
        LevelBadge.elite        => 5,
      };

  // ─── Renk Sistemi ──────────────────────────────────────────────────────────

  /// Kademin ana kimlik rengi.
  Color get color => switch (this) {
        LevelBadge.rookie       => const Color(0xFFE0E0E0), // Soğuk Beyaz
        LevelBadge.beginner     => const Color(0xFF4CAF50), // Canlı Yeşil
        LevelBadge.intermediate => const Color(0xFFCD7F32), // Gerçek Bronz
        LevelBadge.advanced     => const Color(0xFFB0BEC5), // Gümüş-Gri
        LevelBadge.elite        => const Color(0xFFFFD700), // Saf Altın
      };

  /// Badge arka planı için %15 opaklıklı renk (container fill).
  Color get backgroundColor =>
      color.withValues(alpha: 0.15);

  /// Parlama efekti için %30 opaklıklı renk (glow/shadow).
  Color get glowColor =>
      color.withValues(alpha: 0.30);

  /// İkon + border için gradient (iki kademe ton farkı).
  LinearGradient get gradient => LinearGradient(
        colors: [color, _darken(color, 0.15)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ─── İkon Sistemi ──────────────────────────────────────────────────────────

  /// Kademin temsili ikonu.
  IconData get icon => switch (this) {
        LevelBadge.rookie       => Icons.fitness_center_outlined,
        LevelBadge.beginner     => Icons.emoji_events_outlined,     // Madalya
        LevelBadge.intermediate => Icons.fitness_center,            // Dolu Halter
        LevelBadge.advanced     => Icons.sports_martial_arts,       // Kaslı figür
        LevelBadge.elite        => Icons.whatshot,                  // Alev 🔥
      };

  /// Büyük görünüm için ikileme ikonu (XP ekranı, profil detayı vb.).
  IconData get secondaryIcon => switch (this) {
        LevelBadge.rookie       => Icons.radio_button_unchecked,
        LevelBadge.beginner     => Icons.star_border,
        LevelBadge.intermediate => Icons.star_half,
        LevelBadge.advanced     => Icons.star,
        LevelBadge.elite        => Icons.military_tech,
      };

  // ─── Seviye Aralıkları ─────────────────────────────────────────────────────

  /// Bu kademedeki minimum seviye.
  int get minLevel => switch (this) {
        LevelBadge.rookie       => 1,
        LevelBadge.beginner     => 6,
        LevelBadge.intermediate => 16,
        LevelBadge.advanced     => 36,
        LevelBadge.elite        => 61,
      };

  /// Bu kademedeki maksimum seviye (elite için sınır yok → maxInt).
  int get maxLevel => switch (this) {
        LevelBadge.rookie       => 5,
        LevelBadge.beginner     => 15,
        LevelBadge.intermediate => 35,
        LevelBadge.advanced     => 60,
        LevelBadge.elite        => 999,
      };

  /// Bu kademenin toplam seviye aralığı içindeki ilerleme [0.0–1.0].
  /// Elite için her zaman 1.0 döner.
  double progressInTier(int currentLevel) {
    if (this == LevelBadge.elite) return 1.0;
    final range = maxLevel - minLevel + 1;
    final offset = (currentLevel - minLevel).clamp(0, range);
    return offset / range;
  }

  // ─── Factory ───────────────────────────────────────────────────────────────

  /// [level] değerinden doğru [LevelBadge]'i döner.
  ///
  /// Geçersiz (≤ 0) değerler [LevelBadge.rookie] olarak ele alınır.
  static LevelBadge fromLevel(int level) {
    if (level <= 5)  return LevelBadge.rookie;
    if (level <= 15) return LevelBadge.beginner;
    if (level <= 35) return LevelBadge.intermediate;
    if (level <= 60) return LevelBadge.advanced;
    return LevelBadge.elite;
  }
}

// ─── Dahili Yardımcı ────────────────────────────────────────────────────────

/// Bir rengi [amount] oranında koyulaştırır [0.0–1.0].
Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
      .toColor();
}
