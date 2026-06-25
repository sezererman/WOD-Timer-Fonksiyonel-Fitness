import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/utils/input_sanitizer.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../../domain/entities/exercise_entity.dart';
import '../../../domain/entities/workout_share_entity.dart';
import '../../../domain/repositories/workout_share_repository.dart';
import 'workout_share_form_state.dart';

class WorkoutShareFormCubit extends Cubit<WorkoutShareFormState> {
  final WorkoutShareRepository repository;
  final AuthBloc authBloc;

  WorkoutShareFormCubit({
    required this.repository,
    required this.authBloc,
  }) : super(const WorkoutShareFormState());

  void setWorkoutType(String type) {
    emit(state.copyWith(workoutType: type));
  }

  void setDuration(int seconds) {
    emit(state.copyWith(durationSeconds: seconds));
  }

  void updateTips(String tips) {
    emit(state.copyWith(tips: tips));
  }

  void addExercise(String name, int? sets, int? reps) {
    if (name.trim().isEmpty) return;
    
    final newExercise = ExerciseEntity(
      name: name.trim(),
      sets: sets,
      reps: reps,
    );
    
    emit(state.copyWith(
      exercises: List.of(state.exercises)..add(newExercise),
    ));
  }

  void removeExercise(int index) {
    if (index < 0 || index >= state.exercises.length) return;
    
    final updatedList = List<ExerciseEntity>.from(state.exercises)..removeAt(index);
    emit(state.copyWith(exercises: updatedList));
  }

  Future<void> submit() async {
    if (!state.isValid) return;

    emit(state.copyWith(isSubmitting: true));

    try {
      final authState = authBloc.state;
      if (authState is! Authenticated) {
        throw Exception('Antrenman paylaşmak için giriş yapmalısınız.');
      }

      final sanitizedTips = InputSanitizer.sanitizeTips(state.tips);

      final newPost = WorkoutShareEntity(
        id: const Uuid().v4(),
        userId: authState.user.id,
        workoutType: state.workoutType,
        durationSeconds: state.durationSeconds,
        date: DateTime.now(),
        notes: sanitizedTips,
        exercises: state.exercises,
      );

      await repository.shareWorkout(newPost);
      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }
}
