import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/route_constants.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../domain/entities/timer_config.dart';
import '../bloc/timer_bloc.dart';
import '../bloc/timer_event.dart';
import '../bloc/timer_state.dart';
import '../widgets/timer_display.dart';
import '../widgets/phase_banner.dart';
import '../widgets/timer_controls.dart';
import '../../domain/entities/timer_phase.dart';
import '../../../../features/history/presentation/bloc/badges_bloc.dart';
import '../../../../features/history/presentation/bloc/badges_event.dart';

/// Ana timer ekranı.
///
/// PERFORMANS:
/// - StatefulWidget: initState'te tek seferlik TimerStarted event'i.
/// - Üç ayrı BlocBuilder + buildWhen: Her alt widget yalnızca
///   ilgili state değiştiğinde rebuild edilir. Tüm sayfa saniyede
///   bir rebuild olmaz.
class TimerPage extends StatefulWidget {
  final TimerConfig config;

  const TimerPage({super.key, required this.config});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  @override
  void initState() {
    super.initState();
    // addPostFrameCallback: Bir kez, mount sonrası çalışır.
    // Önceki pattern her TimerInitial state'inde callback biriktiriyordu.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TimerBloc>().add(TimerStarted(widget.config));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: GradientBackground(
        // Sayfa iskelet (AppBar + GradientBackground + SafeArea)
        // artık rebuild edilmiyor — yalnızca BlocBuilder'lar rebuild oluyor.
        child: SafeArea(
          child: BlocListener<TimerBloc, TimerState>(
            listener: (context, state) {
              if (state is TimerCompleted) {
                // Timer bittiğinde yeni rozet var mı diye kontrol et
                context.read<BadgesBloc>().add(const CheckForNewBadges());
              } else if (state is TimerAborted) {
                context.pop();
              }
            },
            child: BlocBuilder<TimerBloc, TimerState>(
            // Yalnızca makro state geçişlerinde (Initial→Running, Running→Completed)
            // tüm body rebuild edilir.
            buildWhen: (prev, curr) {
              if (prev.runtimeType == curr.runtimeType &&
                  prev is TimerActiveState &&
                  curr is TimerActiveState) {
                // Aynı macro state — granular builder'lar halledecek
                return false;
              }
              return true;
            },
            builder: (context, state) {
              if (state is TimerInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (state is TimerCompleted) {
                return _TimerCompletedView(
                  state: state,
                  config: widget.config,
                );
              }
              if (state is TimerActiveState) {
                return _TimerActiveView(config: widget.config);
              }
              return const SizedBox.shrink();
            },
          ),
         ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Aktif Timer Görünümü — Granular BlocBuilder'lar
// ─────────────────────────────────────────────────────────────────────────────

class _TimerActiveView extends StatelessWidget {
  final TimerConfig config;
  const _TimerActiveView({required this.config});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      // Phase veya isRunning/isPaused değişince arka plan güncellenir
      buildWhen: (prev, curr) {
        if (prev is TimerActiveState && curr is TimerActiveState) {
          return prev.phase != curr.phase ||
              prev.runtimeType != curr.runtimeType;
        }
        return true;
      },
      builder: (context, state) {
        if (state is! TimerActiveState) return const SizedBox.shrink();
        final phaseColor = state.phase.color;
        final isRunning = state is TimerRunning;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: phaseColor.withValues(alpha: 0.15),
          child: Stack(
            children: [
              // Dekoratif faz yazısı — phase değişmeyince rebuild yok
              // PERFORMANS: Opacity widget — offscreen compositing layer kullanır.
              // Sabit opacity değerleri için Color alpha'ıya taşımak daha verimli.
              // 0x0D ≈ 0.05 * 255 — görsel sonuç aynı, layer yok.
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    state.phase.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w900,
                      color: Color(0x0DFFFFFF), // Colors.white @ 5% opacity
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    PhaseBanner(phase: state.phase),
                    const Spacer(),

                    // ── GRANULAR BUILDER 1: Yalnızca sayaç + halka
                    // Saniyede bir rebuild — yalnızca bu widget rebuild oluyor
                    BlocBuilder<TimerBloc, TimerState>(
                      buildWhen: (prev, curr) {
                        if (prev is TimerActiveState && curr is TimerActiveState) {
                          return prev.remainingSeconds != curr.remainingSeconds ||
                              prev.progress != curr.progress;
                        }
                        return true;
                      },
                      builder: (context, timerState) {
                        if (timerState is! TimerActiveState) {
                          return const SizedBox.shrink();
                        }
                        return TimerDisplay(
                          remainingSeconds: timerState.remainingSeconds,
                          totalPhaseSeconds: timerState.totalPhaseSeconds,
                          phase: timerState.phase,
                          progress: timerState.progress,
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── GRANULAR BUILDER 2: Round sayısı
                    BlocBuilder<TimerBloc, TimerState>(
                      buildWhen: (prev, curr) {
                        if (prev is TimerActiveState && curr is TimerActiveState) {
                          return prev.currentRound != curr.currentRound;
                        }
                        return true;
                      },
                      builder: (context, roundState) {
                        if (roundState is! TimerActiveState) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          'ROUND ${roundState.currentRound}'
                          '${roundState.totalRounds > 0 ? " / ${roundState.totalRounds}" : ""}',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: phaseColor,
                            letterSpacing: 2,
                          ),
                        );
                      },
                    ),

                    const Spacer(),

                    if (config.requiresManualRoundIncrement && isRunning)
                      _AmrapRoundButton(phaseColor: phaseColor),

                    // ── GRANULAR BUILDER 3: Kontrol butonları
                    // Yalnızca running↔paused geçişinde rebuild
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: BlocBuilder<TimerBloc, TimerState>(
                        buildWhen: (prev, curr) {
                          return (prev is TimerRunning) != (curr is TimerRunning) ||
                              (prev is TimerPausedState) != (curr is TimerPausedState);
                        },
                        builder: (context, controlState) {
                          return TimerControls(
                            state: controlState is TimerRunning 
                                ? TimerControlsState.running 
                                : TimerControlsState.paused,
                            onStart: () => context.read<TimerBloc>().add(TimerStarted(config)),
                            onPause: () => context.read<TimerBloc>().add(const TimerPaused()),
                            onResume: () => context.read<TimerBloc>().add(const TimerResumed()),
                            onReset: () {
                              context.read<TimerBloc>().add(const TimerReset());
                              context.read<TimerBloc>().add(TimerStarted(config));
                            },
                            onEndWorkout: () => _showStopDialog(context),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStopDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Antrenmanı İptal Et',
          style: TextStyle(color: Colors.white, fontFamily: 'Orbitron', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Antrenmanı erken sonlandırmak istediğinize emin misiniz? İlerlemeniz kaydedilmeyecektir.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // dialog'u kapat
              parentContext.read<TimerBloc>().add(const TimerStopped());
            },
            child: const Text('Sonlandır', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tamamlandı Görünümü
// ─────────────────────────────────────────────────────────────────────────────

class _TimerCompletedView extends StatelessWidget {
  final TimerCompleted state;
  final TimerConfig config;

  const _TimerCompletedView({required this.state, required this.config});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.backgroundDark,
      child: SizedBox(
        width: double.infinity,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events_rounded, size: 120, color: AppColors.primary),
          const SizedBox(height: 24),
          const Text(
            'WORKOUT COMPLETE',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToShare(context),
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            label: const Text(
              'SHARE TO COMMUNITY',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 10,
              shadowColor: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 32),
          TimerControls(
            state: TimerControlsState.completed,
            onStart: () {},
            onPause: () {},
            onResume: () {},
            onReset: () {
              context.read<TimerBloc>().add(const TimerReset());
              context.read<TimerBloc>().add(TimerStarted(config));
            },
            onEndWorkout: () {},
          ),
        ],
      ),
      ),
    );
  }

  void _navigateToShare(BuildContext context) {
    context.push(Routes.shareWorkout);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AMRAP Round Butonu
// ─────────────────────────────────────────────────────────────────────────────

class _AmrapRoundButton extends StatelessWidget {
  final Color phaseColor;

  const _AmrapRoundButton({required this.phaseColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: SizedBox(
        width: double.infinity,
        height: 100,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: phaseColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            shadowColor: phaseColor.withValues(alpha: 0.5),
          ),
          onPressed: () => context.read<TimerBloc>().add(const TimerRoundIncremented()),
          child: const Text(
            '+1 ROUND',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
