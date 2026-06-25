import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Timer fazlarını temsil eden enum.
enum TimerPhase {
  /// Hazırlık fazı (3-2-1 geri sayım).
  prepare,

  /// Çalışma fazı.
  work,

  /// Dinlenme fazı.
  rest,

  /// Soğuma fazı.
  cooldown,
}

extension TimerPhaseColor on TimerPhase {
  Color get color => switch (this) {
    TimerPhase.work => AppColors.workPhase,
    TimerPhase.rest => AppColors.restPhase,
    TimerPhase.prepare => AppColors.preparePhase,
    TimerPhase.cooldown => AppColors.cooldownPhase,
  };
}
