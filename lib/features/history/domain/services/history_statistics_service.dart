import '../entities/workout_record.dart';
import '../entities/workout_stats.dart';
import 'i_history_statistics_service.dart';

/// Antrenman kayıtlarından istatistikleri hesaplayan servis (Single Responsibility).
class HistoryStatisticsService implements IHistoryStatisticsService {
  @override
  WorkoutStats calculate(List<WorkoutRecord> records) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    int totalSeconds = 0;
    int weeklyCount = 0;
    int monthlyCount = 0;
    final Map<String, int> modeCounts = {};

    for (final record in records) {
      totalSeconds += record.totalSeconds;

      if (record.date.isAfter(weekAgo)) {
        weeklyCount++;
      }

      if (record.date.isAfter(monthAgo)) {
        monthlyCount++;
      }

      modeCounts[record.modeName] = (modeCounts[record.modeName] ?? 0) + 1;
    }

    return WorkoutStats(
      totalWorkouts: records.length,
      totalSeconds: totalSeconds,
      weeklyWorkouts: weeklyCount,
      monthlyWorkouts: monthlyCount,
      workoutsByMode: modeCounts,
    );
  }
}
