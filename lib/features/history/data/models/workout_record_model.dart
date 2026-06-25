import '../../domain/entities/workout_record.dart';

/// WorkoutRecord Hive serileştirme modeli.
class WorkoutRecordModel {
  final String id;
  final String modeName;
  final int totalSeconds;
  final int rounds;
  final int workSeconds;
  final int restSeconds;
  final String date;

  const WorkoutRecordModel({
    required this.id,
    required this.modeName,
    required this.totalSeconds,
    required this.rounds,
    required this.workSeconds,
    required this.restSeconds,
    required this.date,
  });

  factory WorkoutRecordModel.fromEntity(WorkoutRecord entity) {
    return WorkoutRecordModel(
      id: entity.id,
      modeName: entity.modeName,
      totalSeconds: entity.totalSeconds,
      rounds: entity.rounds,
      workSeconds: entity.workSeconds,
      restSeconds: entity.restSeconds,
      date: entity.date.toIso8601String(),
    );
  }

  factory WorkoutRecordModel.fromMap(Map<String, dynamic> map) {
    return WorkoutRecordModel(
      id: map['id'] as String? ?? '',
      modeName: map['modeName'] as String? ?? '',
      totalSeconds: map['totalSeconds'] as int? ?? 0,
      rounds: map['rounds'] as int? ?? 0,
      workSeconds: map['workSeconds'] as int? ?? 0,
      restSeconds: map['restSeconds'] as int? ?? 0,
      date: map['date'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  WorkoutRecord toEntity() {
    return WorkoutRecord(
      id: id,
      modeName: modeName,
      totalSeconds: totalSeconds,
      rounds: rounds,
      workSeconds: workSeconds,
      restSeconds: restSeconds,
      date: DateTime.parse(date),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'modeName': modeName,
      'totalSeconds': totalSeconds,
      'rounds': rounds,
      'workSeconds': workSeconds,
      'restSeconds': restSeconds,
      'date': date,
    };
  }
}
