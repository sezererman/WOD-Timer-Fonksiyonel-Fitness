import '../../domain/entities/exercise_entity.dart';

class ExerciseModel extends ExerciseEntity {
  const ExerciseModel({
    required super.name,
    super.sets,
    super.reps,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      name: json['name'] as String,
      sets: json['sets'] as int?,
      reps: json['reps'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (sets != null) 'sets': sets,
      if (reps != null) 'reps': reps,
    };
  }

  factory ExerciseModel.fromEntity(ExerciseEntity entity) {
    return ExerciseModel(
      name: entity.name,
      sets: entity.sets,
      reps: entity.reps,
    );
  }
}
