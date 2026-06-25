import 'package:flutter/material.dart';
import '../../domain/models/user_level_model.dart';
import '../bloc/level_state.dart';
import '../extensions/player_tier_colors.dart';

/// Level-Up anında gösterilen kutlama popup'ı.
///
/// Kullanım:
/// ```dart
/// BlocListener<LevelBloc, LevelState>(
///   listener: (context, state) {
///     if (state is LevelUpOccurred) {
///       showDialog(
///         context: context,
///         barrierDismissible: false,
///         builder: (_) => LevelUpPopup(state: state),
///       );
///     }
///   },
/// )
/// ```
class LevelUpPopup extends StatefulWidget {
  final LevelUpOccurred state;
  final VoidCallback? onDismissed;

  const LevelUpPopup({
    super.key,
    required this.state,
    this.onDismissed,
  });

  @override
  State<LevelUpPopup> createState() => _LevelUpPopupState();
}

class _LevelUpPopupState extends State<LevelUpPopup>
    with TickerProviderStateMixin {
  // ── Animasyon kontrolcüleri ──────────────────────────────────────────────
  late final AnimationController _scaleController;
  late final AnimationController _glowController;
  late final AnimationController _xpController;

  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;
  late final Animation<double> _glowAnim;
  late final Animation<double> _xpSlideAnim;

  @override
  void initState() {
    super.initState();

    // Kart scale-in animasyonu
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _opacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: const Interval(0, 0.4)),
    );

    // Sürekli parlayan glow efekti
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 4, end: 18).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // XP badge slide-up animasyonu
    _xpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _xpSlideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _xpController, curve: Curves.easeOut),
    );

    // Animasyonları sırayla başlat
    _scaleController.forward().then((_) => _xpController.forward());
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newTier = UserLevelModel.tierFromLevel(widget.state.level);
    final tierColor = newTier.primaryColor;
    final tierAccent = newTier.accentColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: FadeTransition(
        opacity: _opacityAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedBuilder(
            animation: _glowAnim,
            builder: (context, child) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                      Color.alphaBlend(
                        tierColor.withAlpha(51),
                        const Color(0xFF0F3460),
                      ),
                    ],
                  ),
                  border: Border.all(
                    color: tierColor.withAlpha(180),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: tierColor.withAlpha(90),
                      blurRadius: _glowAnim.value * 2,
                      spreadRadius: _glowAnim.value / 4,
                    ),
                  ],
                ),
                child: child!,
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Tier ikonu / rozeti ──────────────────────────────────
                  _TierBadge(tier: newTier, color: tierColor),
                  const SizedBox(height: 20),

                  // ── "SEVİYE ATLANDI!" başlığı ────────────────────────────
                  Text(
                    'SEVİYE ATLANDI!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                      color: tierAccent,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Level numarası ───────────────────────────────────────
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [tierColor, tierAccent],
                    ).createShader(bounds),
                    child: Text(
                      'LEVEL ${widget.state.level}',
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ── Tier ismi ────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: tierColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: tierColor.withAlpha(100)),
                    ),
                    child: Text(
                      '${newTier.icon}  ${newTier.displayName}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: tierColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── XP Breakdown ─────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _xpSlideAnim,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, _xpSlideAnim.value),
                      child: Opacity(
                        opacity:
                            (1 - (_xpSlideAnim.value / 30)).clamp(0.0, 1.0),
                        child: child,
                      ),
                    ),
                    child: _XpBreakdownCard(
                      xpAwarded: widget.state.xpAwarded,
                      breakdown: widget.state.xpBreakdown,
                      color: tierColor,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Kapat butonu ─────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onDismissed?.call();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tierColor,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'DEVAM ET',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TIER BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _TierBadge extends StatelessWidget {
  final PlayerTier tier;
  final Color color;

  const _TierBadge({required this.tier, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withAlpha(80),
            color.withAlpha(30),
          ],
        ),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          tier.icon,
          style: const TextStyle(fontSize: 42),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// XP BREAKDOWN KARTI
// ─────────────────────────────────────────────────────────────────────────────

class _XpBreakdownCard extends StatelessWidget {
  final int xpAwarded;
  final Map<String, int> breakdown;
  final Color color;

  static const _labels = <String, String>{
    'base_xp': '⏱ Antrenman Süresi',
    'amrap_bonus': '🔄 AMRAP Turu Bonusu',
    'fortime_bonus': '⚡ For Time Erken Bitiş',
    'completion_bonus': '✅ EMOM/Tabata Tamamlama',
    'first_daily_bonus': '🌅 İlk Günlük Antrenman',
    'streak_bonus': '🔥 Streak Bonusu',
  };

  const _XpBreakdownCard({
    required this.xpAwarded,
    required this.breakdown,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final nonZeroEntries = breakdown.entries
        .where((e) => e.value > 0 && _labels.containsKey(e.key))
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        children: [
          // Toplam XP
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '+',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                '$xpAwarded XP',
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (nonZeroEntries.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 10),
            // Breakdown satırları
            ...nonZeroEntries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _labels[e.key]!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '+${e.value} XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
