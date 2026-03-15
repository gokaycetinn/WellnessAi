import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wellness_ai/core/services/local_storage_service.dart';
import 'chat_history_state.dart';

class ChatHistoryCubit extends Cubit<ChatHistoryState> {
  final LocalStorageService localStorageService;

  ChatHistoryCubit({required this.localStorageService})
      : super(ChatHistoryInitial());

  Future<void> loadHistory() async {
    emit(ChatHistoryLoading());

    try {
      final sessions = await localStorageService.getAllSessions();
      emit(ChatHistoryLoaded(sessions: sessions));
    } catch (e) {
      emit(ChatHistoryError(message: e.toString()));
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await localStorageService.deleteSession(sessionId);
      await loadHistory();
    } catch (e) {
      emit(ChatHistoryError(message: e.toString()));
    }
  }

  Future<void> archiveSession(String sessionId) async {
    try {
      await localStorageService.archiveSession(sessionId);
      await loadHistory();
    } catch (e) {
      emit(ChatHistoryError(message: e.toString()));
    }
  }

  Future<void> unarchiveSession(String sessionId) async {
    try {
      await localStorageService.unarchiveSession(sessionId);
      await loadHistory();
    } catch (e) {
      emit(ChatHistoryError(message: e.toString()));
    }
  }
}
