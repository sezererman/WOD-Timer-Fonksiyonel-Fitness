import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/level_badge.dart';

// =============================================================================
// UserLevelBadge — Seviye Rozeti Widget'ı
//
// Üç boyuta sahip tam yeniden kullanılabilir badge:
//   • UserLevelBadge.small  → 28px (liste satırları, comment, kart köşesi)
//   • UserLevelBadge.medium → 40px (profil özet satırı, leaderboard)  [default]
//   • UserLevelBadge.large  → 72px (profil sayfası ana rozet)
//
// Kullanım:
//   UserLevelBadge(level: 42)
//   UserLevelBadge.large(level: 42)
//   UserLevelBadge.small(level: 7, showLabel: false)
// =============================================================================

/// Badge görüntülenme boyutu.
enum BadgeSize { small, medium, large }

class UserLevelBadge extends StatelessWidget {
  final int level;
  final BadgeSize size;

  /// Kademe adını ("Rookie", "Elite" vb.) rozetin altında göster.
  final bool showLabel;

  /// Seviye numarasını rozetin içinde göster.
  final bool showLevel;

  const UserLevelBadge({
    super.key,
    required this.level,
    this.size = BadgeSize.medium,
    this.showLabel = true,
    this.showLevel = true,
  });

  // ─── Named Constructors ──────────────────────────────────────────────────

  const UserLevelBadge.small({
    super.key,
    required this.level,
    this.showLabel = false,
    this.showLevel = false,
  }) : size = BadgeSize.small;

  const UserLevelBadge.large({
    super.key,
    required this.level,
    this.showLabel = true,
    this.showLevel = true,
  }) : size = BadgeSize.large;

  // ─── Boyut Sabitleri ─────────────────────────────────────────────────────

  double get _containerSize => switch (size) {
        BadgeSize.small  => 28,
        BadgeSize.medium => 44,
        BadgeSize.large  => 80,
      };

  double get _iconSize => switch (size) {
        BadgeSize.small  => 14,
        BadgeSize.medium => 22,
        BadgeSize.large  => 36,
      };

  double get _borderWidth => switch (size) {
        BadgeSize.small  => 1.5,
        BadgeSize.medium => 2.0,
        BadgeSize.large  => 2.5,
      };

  double get _blurRadius => switch (size) {
        BadgeSize.small  => 8,
        BadgeSize.medium => 14,
        BadgeSize.large  => 28,
      };

  double get _labelFontSize => switch (size) {
        BadgeSize.small  => 9,
        BadgeSize.medium => 11,
        BadgeSize.large  => 13,
      };

  double get _levelFontSize => switch (size) {
        BadgeSize.small  => 7,
        BadgeSize.medium => 9,
        BadgeSize.large  => 14,
      };

  @override
  Widget build(BuildContext context) {
    final badge = LevelBadgeX.fromLevel(level);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BadgeContainer(
          badge: badge,
          level: level,
          containerSize: _containerSize,
          iconSize: _iconSize,
          borderWidth: _borderWidth,
          blurRadius: _blurRadius,
          levelFontSize: _levelFontSize,
          showLevel: showLevel,
          size: size,
        ),
        if (showLabel) ...[
          const SizedBox(height: 6),
          _BadgeLabel(
            badge: badge,
            fontSize: _labelFontSize,
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// _BadgeContainer — Rozetin Ana Gövdesi
// =============================================================================

class _BadgeContainer extends StatelessWidget {
  final LevelBadge badge;
  final int level;
  final double containerSize;
  final double iconSize;
  final double borderWidth;
  final double blurRadius;
  final double levelFontSize;
  final bool showLevel;
  final BadgeSize size;

  const _BadgeContainer({
    required this.badge,
    required this.level,
    required this.containerSize,
    required this.iconSize,
    required this.borderWidth,
    required this.blurRadius,
    required this.levelFontSize,
    required this.showLevel,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Dış Parlama (Glow) ───────────────────────────────────────────────
        Container(
          width: containerSize + blurRadius * 0.6,
          height: containerSize + blurRadius * 0.6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: badge.glowColor,
                blurRadius: blurRadius,
                spreadRadius: badge == LevelBadge.elite ? 4 : 0,
              ),
            ],
          ),
        ),

        // ── Ana Badge Konteyneri ─────────────────────────────────────────────
        Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                badge.backgroundColor,
                badge.color.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: badge.color.withValues(alpha: 0.7),
              width: borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: badge.color.withValues(alpha: 0.20),
                blurRadius: blurRadius * 0.5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildContent(),
        ),

        // ── Elite: Köşe Yıldız Rozeti ────────────────────────────────────────
        if (badge == LevelBadge.elite && size != BadgeSize.small)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: containerSize * 0.30,
              height: containerSize * 0.30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badge.color,
                boxShadow: [
                  BoxShadow(
                    color: badge.glowColor,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                Icons.star,
                color: Colors.white,
                size: containerSize * 0.16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    if (showLevel && size == BadgeSize.large) {
      // Large: İkon üstte, seviye numarası altta
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(badge.icon, color: badge.color, size: iconSize),
          const SizedBox(height: 2),
          Text(
            'LVL $level',
            style: GoogleFonts.orbitron(
              fontSize: levelFontSize,
              fontWeight: FontWeight.w900,
              color: badge.color,
              height: 1,
            ),
          ),
        ],
      );
    }

    // Small / Medium: Sadece ikon (temiz ve okunabilir)
    return Icon(
      badge.icon,
      color: badge.color,
      size: iconSize,
    );
  }
}

// =============================================================================
// _BadgeLabel — Kademe Adı Etiketi
// =============================================================================

class _BadgeLabel extends StatelessWidget {
  final LevelBadge badge;
  final double fontSize;

  const _BadgeLabel({required this.badge, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: badge.backgroundColor,
        border: Border.all(
          color: badge.color.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        badge.label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: badge.color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// =============================================================================
// UserLevelBadgeRow — Rozet + Seviye İlerlemesi (Yatay)
//
// Profil kartları ve topluluk akışında kullanım için hazır bileşik widget.
//
// Kullanım:
//   UserLevelBadgeRow(level: 23, showProgressBar: true)
// =============================================================================

class UserLevelBadgeRow extends StatelessWidget {
  final int level;
  final bool showProgressBar;

  const UserLevelBadgeRow({
    super.key,
    required this.level,
    this.showProgressBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final badge = LevelBadgeX.fromLevel(level);
    final progress = badge.progressInTier(level);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        UserLevelBadge.small(level: level),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  badge.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: badge.color,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Lv.$level',
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badge.color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            if (showProgressBar) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: 100,
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: badge.color.withValues(alpha: 0.15),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(badge.color),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
