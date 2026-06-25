import 'package:equatable/equatable.dart';
import '../../domain/entities/workout_record.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class HistoryLoaded extends HistoryEvent {
  const HistoryLoaded();
}

class HistoryWorkoutDeleted extends HistoryEvent {
  final String id;
  const HistoryWorkoutDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class HistoryWorkoutSaved extends HistoryEvent {
  final WorkoutRecord record;
  const HistoryWorkoutSaved(this.record);
  @override
  List<Object?> get props => [record];
}
