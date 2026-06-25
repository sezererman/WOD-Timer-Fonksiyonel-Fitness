import 'package:equatable/equatable.dart';
import '../../../domain/entities/exercise_entity.dart';

class WorkoutShareFormState extends Equatable {
  final String workoutType;
  final int durationSeconds;
  final List<ExerciseEntity> exercises;
  final String tips;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  const WorkoutShareFormState({
    this.workoutType = 'AMRAP',
    this.durationSeconds = 0,
    this.exercises = const [],
    this.tips = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  bool get isValid {
    return durationSeconds > 0 && exercises.isNotEmpty;
  }

  WorkoutShareFormState copyWith({
    String? workoutType,
    int? durationSeconds,
    List<ExerciseEntity>? exercises,
    String? tips,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return WorkoutShareFormState(
      workoutType: workoutType ?? this.workoutType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      exercises: exercises ?? this.exercises,
      tips: tips ?? this.tips,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage, // Bilerek null yapılabilir
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
        workoutType,
        durationSeconds,
        exercises,
        tips,
        isSubmitting,
        errorMessage,
        isSuccess,
      ];
}
