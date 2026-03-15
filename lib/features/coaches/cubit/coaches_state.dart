import 'package:equatable/equatable.dart';
import 'package:wellness_ai/core/models/coach.dart';

abstract class CoachesState extends Equatable {
  const CoachesState();

  @override
  List<Object?> get props => [];
}

class CoachesInitial extends CoachesState {}

class CoachesLoading extends CoachesState {}

class CoachesLoaded extends CoachesState {
  final List<Coach> coaches;

  const CoachesLoaded({required this.coaches});

  @override
  List<Object?> get props => [coaches];
}

class CoachesError extends CoachesState {
  final String message;

  const CoachesError({required this.message});

  @override
  List<Object?> get props => [message];
}
