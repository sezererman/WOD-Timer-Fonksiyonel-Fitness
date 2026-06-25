import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/user_level_model.dart';
import '../extensions/player_tier_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TIER BADGE — Topluluk feed'inde profil fotoğrafının yanında gösterilir
// ─────────────────────────────────────────────────────────────────────────────

/// Kullanıcı seviyesine göre animasyonlu tier rozeti.
///
/// Kullanım (feed kartında avatar yanına):
/// ```dart
/// TierBadgeWidget(level: post.userLevel)
/// ```
class TierBadgeWidget extends StatefulWidget {
  /// Kullanıcının mevcut level'ı. null ise rozet gösterilmez.
  final int? level;

  /// Rozetin dış çapı (varsayılan: 28 — avatar yanı mini rozet).
  final double size;

  /// true ise rozet üzerine tooltip gösterilir.
  final bool showTooltip;

  const TierBadgeWidget({
    super.key,
    required this.level,
    this.size = 28,
    this.showTooltip = true,
  });

  @override
  State<TierBadgeWidget> createState() => _TierBadgeWidgetState();
}

class _TierBadgeWidgetState extends State<TierBadgeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Yalnızca Elite tier'da sürekli pulse animasyonu çal
    final level = widget.level ?? 1;
    final tier = UserLevelModel.tierFromLevel(level);
    if (tier == PlayerTier.elite) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    if (level == null) return const SizedBox.shrink();

    final tier = UserLevelModel.tierFromLevel(level);
    final config = TierBadgeConfig.fromTier(tier, level);

    Widget badge = _buildBadge(config);

    if (widget.showTooltip) {
      badge = Tooltip(
        message: '${config.tierLabel} • Level $level',
        preferBelow: false,
        child: badge,
      );
    }

    return badge;
  }

  Widget _buildBadge(TierBadgeConfig config) {
    if (config.tier == PlayerTier.elite) {
      return _EliteBadge(config: config, pulseAnim: _pulseAnim, size: widget.size);
    }
    return _StandardBadge(config: config, size: widget.size);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BADGE KONFİGÜRASYON — Her tier için renk, ikon, etiket
// ─────────────────────────────────────────────────────────────────────────────

class TierBadgeConfig {
  final PlayerTier tier;
  final String tierLabel;
  final String levelRange;
  final Color primaryColor;
  final Color secondaryColor;
  final Color glowColor;
  final Color borderColor;
  final Color iconColor;
  final Color backgroundColor;
  final IconData icon;
  final double glowRadius;

  const TierBadgeConfig({
    required this.tier,
    required this.tierLabel,
    required this.levelRange,
    required this.primaryColor,
    required this.secondaryColor,
    required this.glowColor,
    required this.borderColor,
    required this.iconColor,
    required this.backgroundColor,
    required this.icon,
    required this.glowRadius,
  });

  factory TierBadgeConfig.fromTier(PlayerTier tier, int level) {
    switch (tier) {
      case PlayerTier.rookie:
        return const TierBadgeConfig(
          tier: PlayerTier.rookie,
          tierLabel: 'Çaylak',
          levelRange: 'LV 1–5',
          primaryColor: Color(0xFFBDBDBD),       // mat gümüş
          secondaryColor: Color(0xFF9E9E9E),
          glowColor: Color(0x22BDBDBD),
          borderColor: Color(0xFF757575),
          iconColor: Color(0xFFEEEEEE),
          backgroundColor: Color(0xFF1C1C1C),
          icon: Icons.fitness_center_rounded,
          glowRadius: 0,
        );

      case PlayerTier.beginner:
        return const TierBadgeConfig(
          tier: PlayerTier.beginner,
          tierLabel: 'Yeni Başlayan',
          levelRange: 'LV 6–15',
          primaryColor: Color(0xFF2ECC71),       // zümrüt yeşil
          secondaryColor: Color(0xFF27AE60),
          glowColor: Color(0x442ECC71),
          borderColor: Color(0xFF27AE60),
          iconColor: Color(0xFFB9F6CA),
          backgroundColor: Color(0xFF0D1F12),
          icon: Icons.bolt_rounded,
          glowRadius: 6,
        );

      case PlayerTier.intermediate:
        return const TierBadgeConfig(
          tier: PlayerTier.intermediate,
          tierLabel: 'Orta',
          levelRange: 'LV 16–35',
          primaryColor: Color(0xFF3498DB),       // elektrik mavisi
          secondaryColor: Color(0xFF2980B9),
          glowColor: Color(0x443498DB),
          borderColor: Color(0xFF2980B9),
          iconColor: Color(0xFFBBDEFB),
          backgroundColor: Color(0xFF0D1420),
          icon: Icons.military_tech_rounded,
          glowRadius: 8,
        );

      case PlayerTier.advanced:
        return const TierBadgeConfig(
          tier: PlayerTier.advanced,
          tierLabel: 'İleri',
          levelRange: 'LV 36–60',
          primaryColor: Color(0xFF9B59B6),       // derin mor
          secondaryColor: Color(0xFF8E44AD),
          glowColor: Color(0x559B59B6),
          borderColor: Color(0xFF8E44AD),
          iconColor: Color(0xFFE1BEE7),
          backgroundColor: Color(0xFF130D1F),
          icon: Icons.workspace_premium_rounded,
          glowRadius: 10,
        );

      case PlayerTier.elite:
        return const TierBadgeConfig(
          tier: PlayerTier.elite,
          tierLabel: 'Elit Sporcu',
          levelRange: 'LV 61+',
          primaryColor: Color(0xFFFFD700),       // saf altın
          secondaryColor: Color(0xFFFFA000),
          glowColor: Color(0x88FFD700),
          borderColor: Color(0xFFFFB300),
          iconColor: Color(0xFFFFD700),
          backgroundColor: Color(0xFF0A0800),
          icon: Icons.local_fire_department_rounded,
          glowRadius: 16,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STANDART ROZET (Rookie → Advanced)
// ─────────────────────────────────────────────────────────────────────────────

class _StandardBadge extends StatelessWidget {
  final TierBadgeConfig config;
  final double size;

  const _StandardBadge({required this.config, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: config.backgroundColor,
        border: Border.all(color: config.borderColor, width: size * 0.06),
        boxShadow: config.glowRadius > 0
            ? [
                BoxShadow(
                  color: config.glowColor,
                  blurRadius: config.glowRadius,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          config.icon,
          size: size * 0.50,
          color: config.iconColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ELİT ROZET — Siyah zemin üzerine altın alev efekti + pulse animasyonu
// ─────────────────────────────────────────────────────────────────────────────

class _EliteBadge extends StatelessWidget {
  final TierBadgeConfig config;
  final Animation<double> pulseAnim;
  final double size;

  const _EliteBadge({
    required this.config,
    required this.pulseAnim,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Dış Glow halkası (pulsating)
            Container(
              width: size * pulseAnim.value,
              height: size * pulseAnim.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: config.glowColor,
                    blurRadius: config.glowRadius * pulseAnim.value,
                    spreadRadius: 2 * pulseAnim.value,
                  ),
                ],
              ),
            ),
            // Ana rozet
            child!,
          ],
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(0, -0.3),
            radius: 0.8,
            colors: [
              Color(0xFF1A1200),    // koyu altın merkez
              Color(0xFF080600),    // siyah kenarda
            ],
          ),
          border: Border.all(
            color: config.borderColor,
            width: size * 0.07,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xAAFFD700),
              blurRadius: config.glowRadius,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0x44FFA000),
              blurRadius: config.glowRadius * 2,
            ),
          ],
        ),
        child: Center(
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFE57F),   // parlak altın üst
                Color(0xFFFFD700),   // altın orta
                Color(0xFFFF8F00),   // bronz alt
              ],
            ).createShader(bounds),
            child: Icon(
              config.icon,
              size: size * 0.52,
              color: Colors.white, // ShaderMask override eder
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AVATARLI ROZET — Profil fotoğrafı + tier rozeti stack'i
// Topluluk feed kartında doğrudan kullanılmak üzere
// ─────────────────────────────────────────────────────────────────────────────

/// Profil avatarının sağ altına tier rozetini konumlandırır.
///
/// ```dart
/// TieredAvatar(
///   avatarUrl: post.userAvatarUrl,
///   displayName: post.userName ?? 'Athlete',
///   level: post.userLevel,
///   radius: 22,
/// )
/// ```
class TieredAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String displayName;
  final int? level;
  final double radius;

  const TieredAvatar({
    super.key,
    this.avatarUrl,
    required this.displayName,
    this.level,
    this.radius = 22,
  });

  String get _initial => displayName.isNotEmpty
      ? displayName.substring(0, 1).toUpperCase()
      : '?';

  @override
  Widget build(BuildContext context) {
    final tier = level != null ? UserLevelModel.tierFromLevel(level!) : null;
    final tierColor = tier?.primaryColor ?? Colors.grey;

    return SizedBox(
      width: radius * 2 + 10,  // rozet için ekstra alan
      height: radius * 2 + 10,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Avatar çemberi ────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: tier != null ? tierColor.withAlpha(180) : Colors.transparent,
                  width: 2,
                ),
                boxShadow: tier != null
                    ? [
                        BoxShadow(
                          color: tierColor.withAlpha(60),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: CircleAvatar(
                radius: radius,
                backgroundColor: const Color(0xFF2A2A40),
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(
                        _initial,
                        style: TextStyle(
                          color: tierColor,
                          fontWeight: FontWeight.bold,
                          fontSize: radius * 0.7,
                        ),
                      )
                    : null,
              ),
            ),
          ),

          // ── Tier rozeti (sağ alt köşe) ───────────────────────────────────
          if (level != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: TierBadgeWidget(
                level: level,
                size: radius * 0.9,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEADERBOARD ROZET SATIRI — Tam boyut rozet + tier adı + level range
// Liderlik tablosu veya profil sayfası için
// ─────────────────────────────────────────────────────────────────────────────

class TierBadgeRow extends StatelessWidget {
  final int level;

  const TierBadgeRow({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final tier = UserLevelModel.tierFromLevel(level);
    final config = TierBadgeConfig.fromTier(tier, level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: config.borderColor.withAlpha(120)),
        boxShadow: [
          BoxShadow(
            color: config.glowColor,
            blurRadius: config.glowRadius,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TierBadgeWidget(level: level, size: 20, showTooltip: false),
          const SizedBox(width: 8),
          Text(
            config.tierLabel,
            style: TextStyle(
              color: config.primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.levelRange,
            style: TextStyle(
              color: config.primaryColor.withAlpha(160),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROZET ŞERIDI — Tüm tier'ları yan yana gösteren tanıtım/showcase widget'ı
// Onboarding veya "Hakkında" ekranında kullanılabilir
// ─────────────────────────────────────────────────────────────────────────────

class TierBadgeShowcase extends StatelessWidget {
  const TierBadgeShowcase({super.key});

  static const _levels = [1, 6, 16, 36, 61];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _levels.map((level) {
        final tier = UserLevelModel.tierFromLevel(level);
        final config = TierBadgeConfig.fromTier(tier, level);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TierBadgeWidget(level: level, size: 44, showTooltip: false),
            const SizedBox(height: 6),
            Text(
              config.tierLabel,
              style: TextStyle(
                color: config.primaryColor,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// YARDIMCI: Spinner animasyonu (Elite alev efekti için referans - genişletilebilir)
// ─────────────────────────────────────────────────────────────────────────────

/// Elite sporcu için dönen hale efekti — isteğe bağlı süsleme.
class EliteHaloEffect extends StatefulWidget {
  final Widget child;
  final double size;

  const EliteHaloEffect({super.key, required this.child, required this.size});

  @override
  State<EliteHaloEffect> createState() => _EliteHaloEffectState();
}

class _EliteHaloEffectState extends State<EliteHaloEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotController;

  @override
  void initState() {
    super.initState();
    _rotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _rotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dönen altın hale
        AnimatedBuilder(
          animation: _rotController,
          builder: (context, _) => Transform.rotate(
            angle: _rotController.value * 2 * math.pi,
            child: CustomPaint(
              size: Size(widget.size * 1.4, widget.size * 1.4),
              painter: _GoldenHaloPainter(),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _GoldenHaloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = const SweepGradient(
        colors: [
          Colors.transparent,
          Color(0xFFFFD700),
          Color(0xFFFFB300),
          Colors.transparent,
        ],
        stops: [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
