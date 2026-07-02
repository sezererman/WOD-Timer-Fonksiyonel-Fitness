import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/community/presentation/pages/community_feed_screen.dart';
import '../../features/community/presentation/pages/share_workout_screen.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/challenges/presentation/pages/challenges_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/workout_modes/presentation/pages/mode_selection_page.dart';
import '../../features/timer/presentation/pages/timer_page.dart';
import '../../features/timer/domain/entities/timer_config.dart';
import 'route_constants.dart';
import 'scaffold_with_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.timer,
    debugLogDiagnostics: kDebugMode,

    // AuthBloc'daki state değişimlerini dinlemek için:
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final bool isAuth = authState is Authenticated;
      final bool isLoggingIn = state.matchedLocation == Routes.login ||
                               state.matchedLocation == Routes.register;

      // 1. KORUMALI ROTALAR (Auth Guard)
      // Topluluk ve Profil sekmeleri giriş gerektirir ancak kullanıcıyı dışarı atmamak
      // ve MiniTimerBar'ın kaybolmasını önlemek için redirect YAPMIYORUZ.
      // Bunun yerine o sayfaların içinde "Giriş Yapmalısınız" UI'ı göstereceğiz.

      // 2. ZATEN GİRİŞ YAPMIŞSA
      // Giriş yapmış kullanıcı login veya register sayfasına gitmeye çalışırsa ana sayfaya yönlendir
      if (isAuth && isLoggingIn) {
        return Routes.timer;
      }

      // 4. SERBEST GEÇİŞ
      // Timer veya Geçmiş (History) gibi korumasız rotalarda geçişe izin ver (Guest Mode)
      return null;
    },

    routes: <RouteBase>[
      GoRoute(
        path: Routes.login,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: Routes.register,
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterPage();
        },
      ),
      GoRoute(
        path: Routes.shareWorkout,
        builder: (BuildContext context, GoRouterState state) {
          return const ShareWorkoutScreen();
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          // Branch 0: Timer
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.timer,
                builder: (BuildContext context, GoRouterState state) {
                  return const ModeSelectionPage();
                },
                routes: [
                  GoRoute(
                    path: 'active',
                    builder: (context, state) {
                      final config = state.extra as TimerConfig?;
                      if (config == null) {
                        return const ModeSelectionPage(); // Fallback
                      }
                      return TimerPage(config: config);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Challenges
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.challenges,
                builder: (BuildContext context, GoRouterState state) {
                  return const ChallengesPage();
                },
              ),
            ],
          ),

          // Branch 2: Sosyal (Community)
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.community,
                builder: (BuildContext context, GoRouterState state) {
                  return const CommunityFeedScreen();
                },
              ),
            ],
          ),

          // Branch 3: Geçmiş
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.history,
                builder: (BuildContext context, GoRouterState state) {
                  return const HistoryPage();
                },
              ),
            ],
          ),

          // Branch 4: Profil (Settings)
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.profile,
                builder: (BuildContext context, GoRouterState state) {
                  return const ProfilePage();
                },
                routes: [
                  GoRoute(
                    path: 'settings', // /profile/settings
                    builder: (context, state) => const SettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Stream'i GoRouter'ın anlayabileceği Listenable'a çeviren yardımcı sınıf.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
