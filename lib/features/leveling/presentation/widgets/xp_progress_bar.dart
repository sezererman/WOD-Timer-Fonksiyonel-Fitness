import 'package:flutter/material.dart';
import '../../domain/models/user_level_model.dart';
import '../bloc/level_state.dart';
import '../extensions/player_tier_colors.dart';

/// XP ilerleme çubuğu — profil sayfasında ve timer tamamlanma ekranında kullanılır.
///
/// Kullanım:
/// ```dart
/// BlocBuilder<LevelBloc, LevelState>(
///   builder: (context, state) {
///     if (state is LevelLoaded) {
///       return XpProgressBar(state: state);
///     }
///     return const SizedBox.shrink();
///   },
/// )
/// ```
class XpProgressBar extends StatelessWidget {
  final LevelLoaded state;

  /// Animasyon süresi. 0 ise animasyon yoktur.
  final Duration animationDuration;

  /// Kompakt mod: sadece progress bar (başlık ve istatistikler gizlenir).
  final bool compact;

  const XpProgressBar({
    super.key,
    required this.state,
    this.animationDuration = const Duration(milliseconds: 800),
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final tier = state.tier;
    final color = tier.primaryColor;
    final accent = tier.accentColor;

    return compact
        ? _CompactBar(
            state: state,
            color: color,
            accent: accent,
            duration: animationDuration,
          )
        : _FullBar(
            state: state,
            color: color,
            accent: accent,
            duration: animationDuration,
          );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAM BOYUT (Profil Sayfası)
// ─────────────────────────────────────────────────────────────────────────────

class _FullBar extends StatelessWidget {
  final LevelLoaded state;
  final Color color;
  final Color accent;
  final Duration duration;

  const _FullBar({
    required this.state,
    required this.color,
    required this.accent,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E),
            Color.alphaBlend(color.withAlpha(30), const Color(0xFF16213E)),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(70)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(40),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Üst satır: Tier badge + Level numarası ───────────────────────
          Row(
            children: [
              // Tier ikonu
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withAlpha(40),
                  border: Border.all(color: color.withAlpha(120)),
                ),
                child: Center(
                  child: Text(
                    state.tier.icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Level ve Tier ismi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.tierName,
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Level ${state.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              // Toplam XP
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${state.totalXp} XP',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Toplam',
                    style: TextStyle(
                      color: Colors.white.withAlpha(100),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Progress Bar ─────────────────────────────────────────────────
          _AnimatedProgressBar(
            progress: state.progressPercentage,
            color: color,
            accent: accent,
            duration: duration,
          ),
          const SizedBox(height: 8),

          // ── XP metni ────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _progressLabel(state),
                style: TextStyle(
                  color: Colors.white.withAlpha(150),
                  fontSize: 12,
                ),
              ),
              Text(
                'Sonraki: Level ${state.level + 1}',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── İstatistikler satırı ─────────────────────────────────────────
          Row(
            children: [
              _StatChip(
                label: 'Streak',
                value: '${state.streakDays} gün',
                icon: '🔥',
                color: color,
              ),
              const SizedBox(width: 10),
              _StatChip(
                label: 'Bugün',
                value: '${state.dailyXpToday} XP',
                icon: '⚡',
                color: accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _progressLabel(LevelLoaded state) {
    final xpInLevel = state.totalXp -
        UserLevelModel.cumulativeXpAtLevelStart(state.level);
    return '$xpInLevel / ${state.currentLevelThreshold} XP';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KOMPAKT (Timer tamamlama ekranı, mini profil kartı vb.)
// ─────────────────────────────────────────────────────────────────────────────

class _CompactBar extends StatelessWidget {
  final LevelLoaded state;
  final Color color;
  final Color accent;
  final Duration duration;

  const _CompactBar({
    required this.state,
    required this.color,
    required this.accent,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Level rozeti
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withAlpha(40),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withAlpha(100)),
          ),
          child: Text(
            'LV ${state.level}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Progress bar
        Expanded(
          child: _AnimatedProgressBar(
            progress: state.progressPercentage,
            color: color,
            accent: accent,
            duration: duration,
            height: 8,
          ),
        ),

        const SizedBox(width: 10),

        // Sonraki level
        Text(
          'LV ${state.level + 1}',
          style: TextStyle(
            color: Colors.white.withAlpha(120),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANİMASYONLU PROGRESS BAR
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final Color accent;
  final Duration duration;
  final double height;

  const _AnimatedProgressBar({
    required this.progress,
    required this.color,
    required this.accent,
    required this.duration,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Stack(
        children: [
          // Arkaplan
          Container(
            height: height,
            color: Colors.white.withAlpha(20),
          ),
          // Doluluk
          AnimatedFractionallySizedBox(
            duration: duration,
            curve: Curves.easeOutCubic,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, accent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(100),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// İSTATİSTİK CHİP
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withAlpha(100),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
