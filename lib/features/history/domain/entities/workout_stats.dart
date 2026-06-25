import 'package:equatable/equatable.dart';

/// Antrenman istatistiklerini temsil eden entity.
class WorkoutStats extends Equatable {
  final int totalWorkouts;
  final int totalSeconds;
  final int weeklyWorkouts;
  final int monthlyWorkouts;
  final Map<String, int> workoutsByMode;

  const WorkoutStats({
    required this.totalWorkouts,
    required this.totalSeconds,
    required this.weeklyWorkouts,
    required this.monthlyWorkouts,
    required this.workoutsByMode,
  });

  @override
  List<Object?> get props => [
        totalWorkouts,
        totalSeconds,
        weeklyWorkouts,
        monthlyWorkouts,
        workoutsByMode,
      ];
}
