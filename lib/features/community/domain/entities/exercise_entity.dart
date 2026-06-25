import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  final String name;
  final int? sets;
  final int? reps;

  const ExerciseEntity({
    required this.name,
    this.sets,
    this.reps,
  });

  ExerciseEntity copyWith({
    String? name,
    int? sets,
    int? reps,
  }) {
    return ExerciseEntity(
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
    );
  }

  @override
  List<Object?> get props => [name, sets, reps];
}
