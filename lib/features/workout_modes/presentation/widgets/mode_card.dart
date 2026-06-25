import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/workout_mode.dart';

/// Mod seçim kartı widget'ı.
class ModeCard extends StatelessWidget {
  final WorkoutMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const ModeCard({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (mode) {
      case WorkoutMode.emom: return Icons.timer_rounded;
      case WorkoutMode.amrap: return Icons.repeat_rounded;
      case WorkoutMode.tabata: return Icons.flash_on_rounded;
      case WorkoutMode.forTime: return Icons.flag_rounded;
      case WorkoutMode.custom: return Icons.tune_rounded;
    }
  }

  String get _title {
    switch (mode) {
      case WorkoutMode.emom: return 'EMOM';
      case WorkoutMode.amrap: return 'AMRAP';
      case WorkoutMode.tabata: return 'TABATA';
      case WorkoutMode.forTime: return 'FOR TIME';
      case WorkoutMode.custom: return 'CUSTOM';
    }
  }

  String get _subtitle {
    switch (mode) {
      case WorkoutMode.emom: return 'Every Minute\nOn the Minute';
      case WorkoutMode.amrap: return 'As Many Reps\nAs Possible';
      case WorkoutMode.tabata: return '20s Work\n10s Rest';
      case WorkoutMode.forTime: return 'Tamamlama\nSüresi';
      case WorkoutMode.custom: return 'Özel\nZamanlayıcı';
    }
  }

  Color get _color {
    switch (mode) {
      case WorkoutMode.emom: return AppColors.primary;
      case WorkoutMode.amrap: return AppColors.secondary;
      case WorkoutMode.tabata: return AppColors.workPhase;
      case WorkoutMode.forTime: return AppColors.restPhase;
      case WorkoutMode.custom: return AppColors.cooldownPhase;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [_color.withValues(alpha: 0.3), _color.withValues(alpha: 0.1)]
                : [AppColors.surfaceLight, AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _color : AppColors.surfaceLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: _color.withValues(alpha: 0.3), blurRadius: 16)]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon, color: _color, size: 32),
            const SizedBox(height: 12),
            Text(
              _title,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? _color : AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
