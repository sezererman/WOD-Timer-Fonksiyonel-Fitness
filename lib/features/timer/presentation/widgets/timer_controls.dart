import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

enum TimerControlsState {
  initial,
  running,
  paused,
  completed,
}

/// Timer kontrol butonları — Play/Pause, Reset, Skip.
class TimerControls extends StatelessWidget {
  final TimerControlsState state;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final VoidCallback onEndWorkout;

  const TimerControls({
    super.key,
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onEndWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final isRunning = state == TimerControlsState.running;
    final isPaused = state == TimerControlsState.paused;
    final isCompleted = state == TimerControlsState.completed;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isRunning || isPaused || isCompleted)
          _ControlButton(
            icon: Icons.replay_rounded,
            color: AppColors.textSecondary,
            onPressed: onReset,
            size: 52,
          ),
        const SizedBox(width: 24),
        if (!isCompleted)
          _ControlButton(
            icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: AppColors.primary,
            onPressed: isRunning ? onPause : (isPaused ? onResume : onStart),
            size: 96,
            isPrimary: true,
          ),
        if (isCompleted)
          _ControlButton(
            icon: Icons.replay_rounded,
            color: AppColors.primary,
            onPressed: onReset,
            size: 72,
            isPrimary: true,
          ),
        const SizedBox(width: 24),
        if (isRunning || isPaused)
          _ControlButton(
            icon: Icons.stop_rounded,
            color: AppColors.textSecondary,
            onPressed: onEndWorkout,
            size: 52,
          ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double size;
  final bool isPrimary;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.size = 56,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(size / 2),
        splashColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.1),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPrimary ? color : color.withValues(alpha: 0.1),
            boxShadow: isPrimary
                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 4))]
                : null,
            border: isPrimary ? null : Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Icon(icon, color: isPrimary ? Colors.white : color, size: size * 0.5),
        ),
      ),
    );
  }
}
