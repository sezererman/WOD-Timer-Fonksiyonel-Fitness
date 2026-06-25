import '../entities/workout_record.dart';
import '../entities/workout_stats.dart';

/// Antrenman istatistiklerini hesaplayan servis arayüzü.
///
/// [HistoryBloc] bu soyut tipe bağlıdır; test ortamında mock'lanabilir.
abstract class IHistoryStatisticsService {
  WorkoutStats calculate(List<WorkoutRecord> records);
}
