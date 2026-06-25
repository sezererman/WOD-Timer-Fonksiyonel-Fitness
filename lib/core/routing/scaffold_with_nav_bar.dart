import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/history/presentation/bloc/badges_bloc.dart';
import '../../features/history/presentation/bloc/badges_state.dart';
import '../../features/history/domain/entities/badge.dart' as domain;
import '../constants/app_colors.dart';
import '../widgets/fitness_bottom_nav_bar.dart';
import '../widgets/mini_timer_bar.dart';
import 'app_tab.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BadgesBloc, BadgesState>(
      listener: (context, state) {
        if (state is NewBadgesEarned) {
          // Rozetleri sırayla göster — zamanlama sorumluluğu UI'da.
          _showBadgesSequentially(context, state.badges);
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(child: navigationShell),
            if (navigationShell.currentIndex != AppTab.timer.index)
              MiniTimerBar(
                onTap: () {
                  navigationShell.goBranch(AppTab.timer.index);
                },
              ),
          ],
        ),
        bottomNavigationBar: FitnessBottomNavBar(
          selectedIndex: navigationShell.currentIndex,
          onItemSelected: (int index) => _onTap(context, index),
        ),
      ),
    );
  }

  /// Rozetleri sırayla animasyonla gösterir.
  /// Kullanıcı her diyaloğu kapattıktan sonra bir sonraki açılır.
  Future<void> _showBadgesSequentially(
    BuildContext context,
    List<domain.Badge> badges,
  ) async {
    for (final badge in badges) {
      if (!context.mounted) return;
      await _showBadgeDialog(context, badge);
    }
  }

  Future<void> _showBadgeDialog(BuildContext context, domain.Badge badge) async {
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
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFD700), width: 2), // Gold border
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
                  // In a real app this would be Image.network or asset
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white10,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.military_tech, size: 60, color: Color(0xFFFFD700)),
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
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: AppColors.backgroundDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('HARİKA', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      // Eğer mevcut açık olan sekmeye tekrar tıklanırsa, onu ilk rotasına sıfırla
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
