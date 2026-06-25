import 'package:equatable/equatable.dart';
import '../../domain/entities/workout_record.dart';
import '../../domain/entities/badge.dart';
import '../../domain/entities/workout_stats.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoadSuccess extends HistoryState {
  final List<WorkoutRecord> records;
  final WorkoutStats stats;
  final List<Badge> earnedBadges;

  const HistoryLoadSuccess({
    required this.records,
    required this.stats,
    this.earnedBadges = const [],
  });

  @override
  List<Object?> get props => [records, stats, earnedBadges];
}

/// Save veya Delete işlemi sırasında geçici yükleme durumu.
class HistoryMutating extends HistoryState {
  const HistoryMutating();
}

/// Save veya Delete işlemi başarısız olduğunda emit edilir.
/// Kullanıcıya sessiz hata yerine bilgi gösterilmesini sağlar.
class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

