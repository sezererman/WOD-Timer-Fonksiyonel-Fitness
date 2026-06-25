import 'package:equatable/equatable.dart';

/// Antrenman geçmişi kaydı.
class WorkoutRecord extends Equatable {
  final String id;
  final String modeName;
  final int totalSeconds;
  final int rounds;
  final int workSeconds;
  final int restSeconds;
  final DateTime date;

  const WorkoutRecord({
    required this.id,
    required this.modeName,
    required this.totalSeconds,
    required this.rounds,
    required this.workSeconds,
    required this.restSeconds,
    required this.date,
  });

  @override
  List<Object?> get props => [id, modeName, totalSeconds, rounds, date];
}
