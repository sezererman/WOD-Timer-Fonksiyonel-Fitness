import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../routing/route_constants.dart';
import '../../features/timer/presentation/bloc/timer_bloc.dart';
import '../../features/timer/presentation/bloc/timer_event.dart';
import '../../features/timer/presentation/bloc/timer_state.dart';
import '../../features/timer/domain/entities/timer_phase.dart';

class MiniTimerBar extends StatelessWidget {
  final VoidCallback? onTap;

  const MiniTimerBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, curr) {
        if (prev is TimerActiveState && curr is TimerActiveState) {
          return prev.remainingSeconds != curr.remainingSeconds ||
                 prev.runtimeType != curr.runtimeType;
        }
        return prev.runtimeType != curr.runtimeType;
      },
      builder: (context, state) {
        if (state is! TimerActiveState) {
          return const SizedBox.shrink(); 
        }

        final isPaused = state is TimerPausedState;
        final phaseName = state.phase.name.toUpperCase();
        
        final phaseColor = state.phase.color;

        final minutes = state.remainingSeconds ~/ 60;
        final seconds = state.remainingSeconds % 60;
        final timeString = '$minutes:${seconds.toString().padLeft(2, '0')}';

        return GestureDetector(
          onTap: onTap ?? () {
            context.go(Routes.timer);
          },
          child: Container(
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: phaseColor.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: phaseColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: phaseColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.timer_outlined, color: phaseColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phaseName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: phaseColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        timeString,
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    if (isPaused) {
                      context.read<TimerBloc>().add(const TimerResumed());
                    } else {
                      context.read<TimerBloc>().add(const TimerPaused());
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
