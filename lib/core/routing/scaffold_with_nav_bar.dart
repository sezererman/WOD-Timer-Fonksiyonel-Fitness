import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/history/presentation/bloc/badges_bloc.dart';
import '../../features/history/presentation/bloc/badges_state.dart';
import '../../features/history/domain/entities/badge.dart' as domain;
import '../../features/timer/presentation/bloc/timer_bloc.dart';
import '../../features/timer/presentation/bloc/timer_state.dart';
import '../../design_system/constants/app_colors.dart';
import '../../design_system/widgets/fitness_bottom_nav_bar.dart';
import '../../design_system/widgets/mini_timer_bar.dart';
import 'app_tab.dart';
import 'route_constants.dart';

/// Ana navigasyon iskeleti.
///
/// ## Tasarım Kararı — Neden _currentIndex ve routerDelegate.addListener YOK?
///
/// Önceki implementasyonda [routerDelegate.addListener] ile tutulan yerel
/// [_currentIndex] state'i bir race condition yaratıyordu:
///
///   1. Kullanıcı Tab-1'e tıklar → optimistic setState(_currentIndex = 1)
///   2. goBranch(1) tetikler → routerDelegate.notifyListeners() SYNC çalışır
///   3. _onRouteChanged() anında çalışır, ama GoRouter henüz branch'i
///      güncellemediği için [navigationShell.currentIndex] hâlâ 0 döner.
///   4. Guard başarısız → setState(_currentIndex = 0) → nav bar GERI ALINDI!
///   5. Kullanıcı nav bar'ın eski sekmeye döndüğünü görür ve ikinci kez tıklar.
///
/// **Doğru yöntem:** [navigationShell.currentIndex]'i doğrudan kaynak olarak
/// kullan. GoRouter [goBranch] işlediğinde [StatefulShellRoute] builder'ını
/// tekrar çağırır → [ScaffoldWithNavBar] yeni [navigationShell] ile rebuild
/// olur → [widget.navigationShell.currentIndex] otomatik güncellenir.
/// Hiçbir state, listener veya race condition gerektirmez.
class ScaffoldWithNavBar extends StatefulWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  /// Mini-player yalnızca Timer sekmesi DIŞINDA görünür.
  /// Doğrudan [widget.navigationShell.currentIndex] okunur — yerel state yok.
  bool get _isOnTimerTab =>
      widget.navigationShell.currentIndex == AppTab.timer.index;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BadgesBloc, BadgesState>(
      listener: (context, state) {
        if (state is NewBadgesEarned) {
          _showBadgesSequentially(context, state.badges);
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(child: widget.navigationShell),

            // ── Mini Player ──────────────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                // ignore: deprecated_member_use
                axisAlignment: -1.0,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: _isOnTimerTab
                  ? const SizedBox.shrink(key: ValueKey('hidden'))
                  : MiniTimerBar(
                      key: const ValueKey('visible'),
                      onTap: () => _navigateToActiveTimer(context),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: FitnessBottomNavBar(
          // ✅ Doğrudan GoRouter kaynağına bağlı — manuel state yok.
          selectedIndex: widget.navigationShell.currentIndex,
          onItemSelected: _onTabTapped,
        ),
      ),
    );
  }

  /// Standart go_router tab geçiş metodu.
  /// Aynı sekmeye tıklanırsa o branch'in kök rotasına sıfırlar (UX best practice).
  void _onTabTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  /// Mini-Player tıklandığında aktif timer ekranına döner.
  ///
  /// Neden [goBranch] değil?
  /// [goBranch(0)] branch index'i zaten 0 ise ya da branch stack /timer
  /// kökündeyse hiçbir şey yapmaz. Bu durumda TimerPage görünmez.
  /// Bunun yerine TimerBloc state'inden mevcut [TimerConfig]'i alarak
  /// [context.go('/timer/active')] ile doğrudan TimerPage'e gidiyoruz.
  /// [extra] parametresi config'i taşır; TimerPage initState'te
  /// [TimerStarted] göndermeden önce BLoC state'i zaten aktif olduğu için
  /// timer kesintisiz devam eder.
  void _navigateToActiveTimer(BuildContext context) {
    final timerState = context.read<TimerBloc>().state;
    if (timerState is TimerActiveState) {
      // Config BLoC state'inden alınır — push stack'i kirletmez, go kullanılır.
      context.go('${Routes.timer}/active', extra: timerState.config);
    } else {
      // Aktif timer yoksa (edge case) kök timer sekmesine git.
      widget.navigationShell.goBranch(
        AppTab.timer.index,
        initialLocation: true,
      );
    }
  }

  // ── Rozet Diyalogları ────────────────────────────────────────────────────────

  Future<void> _showBadgesSequentially(
    BuildContext context,
    List<domain.Badge> badges,
  ) async {
    for (final badge in badges) {
      if (!context.mounted) return;
      await _showBadgeDialog(context, badge);
    }
  }

  Future<void> _showBadgeDialog(
      BuildContext context, domain.Badge badge) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 600),
            tween: Tween<double>(begin: 0, end: 1),
            curve: Curves.elasticOut,
            builder: (context, double value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'TEBRİKLER!',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white10,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.military_tech,
                      size: 60,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    badge.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: AppColors.backgroundDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'HARİKA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
