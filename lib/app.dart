import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'design_system/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/workout_modes/presentation/bloc/workout_mode_bloc.dart';
import 'features/history/presentation/bloc/history_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/community/presentation/bloc/workout_share/workout_share_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/timer/presentation/bloc/timer_bloc.dart';
import 'features/history/presentation/bloc/badges_bloc.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(authBloc: sl<AuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<TimerBloc>()),
        BlocProvider(create: (_) => sl<WorkoutModeBloc>()),
        BlocProvider(create: (_) => sl<HistoryBloc>()),
        BlocProvider(create: (_) => sl<SettingsBloc>()),
        BlocProvider.value(value: sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<WorkoutShareBloc>()),
        BlocProvider(create: (_) => sl<BadgesBloc>()),
      ],
      child: MaterialApp.router(
        title: 'RepBase - WOD & AMRAP Sayacı',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: _appRouter.router,
      ),
    );
  }
}
