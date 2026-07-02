import 'package:equatable/equatable.dart';
import '../constants/sync_status.dart';

/// Antrenman geçmişi kaydı.
class WorkoutRecord extends Equatable {
  final String id;
  final String modeName;
  final int totalSeconds;
  final int rounds;
  final int workSeconds;
  final int restSeconds;
  final DateTime date;
  final String syncStatus;

  const WorkoutRecord({
    required this.id,
    required this.modeName,
    required this.totalSeconds,
    required this.rounds,
    required this.workSeconds,
    required this.restSeconds,
    required this.date,
    this.syncStatus = SyncStatus.pending,
  });

  WorkoutRecord copyWith({
    String? id,
    String? modeName,
    int? totalSeconds,
    int? rounds,
    int? workSeconds,
    int? restSeconds,
    DateTime? date,
    String? syncStatus,
  }) {
    return WorkoutRecord(
      id: id ?? this.id,
      modeName: modeName ?? this.modeName,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      rounds: rounds ?? this.rounds,
      workSeconds: workSeconds ?? this.workSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      date: date ?? this.date,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [id, modeName, totalSeconds, rounds, date, syncStatus];
}
