import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wellness_ai/core/constants/app_constants.dart';
import 'package:wellness_ai/core/models/coach.dart';
import 'package:wellness_ai/core/services/firebase_service.dart';
import 'coaches_state.dart';

class CoachesCubit extends Cubit<CoachesState> {
  final FirebaseService firebaseService;

  CoachesCubit({required this.firebaseService}) : super(CoachesInitial());

  Future<void> loadCoaches() async {
    emit(CoachesLoading());

    try {
      final coaches = AppConstants.coachData.map((data) {
        final coach = Coach.fromMap(data);
        final instruction =
            firebaseService.getSystemInstruction(coach.remoteConfigKey);
        return coach.copyWith(systemInstruction: instruction);
      }).toList();

      emit(CoachesLoaded(coaches: coaches));
    } catch (e) {
      emit(CoachesError(message: e.toString()));
    }
  }
}
