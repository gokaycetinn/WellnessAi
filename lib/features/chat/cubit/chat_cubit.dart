import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:wellness_ai/core/models/chat_message.dart';
import 'package:wellness_ai/core/models/chat_session.dart' as models;
import 'package:wellness_ai/core/models/coach.dart';
import 'package:wellness_ai/core/services/ai_service.dart';
import 'package:wellness_ai/core/services/local_storage_service.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final AiService aiService;
  final LocalStorageService localStorageService;
  final Uuid _uuid = const Uuid();

  Coach? _currentCoach;
  String? _currentSessionId;
  List<ChatMessage> _messages = [];

  ChatCubit({
    required this.aiService,
    required this.localStorageService,
  }) : super(ChatInitial());

  Coach? get currentCoach => _currentCoach;
  String? get currentSessionId => _currentSessionId;

  /// Start a new chat session with a coach
  Future<void> startNewSession(Coach coach) async {
    emit(ChatLoading());
    _currentCoach = coach;
    _currentSessionId = _uuid.v4();
    _messages = [];

    // Clear any existing AI session for this coach to start fresh
    aiService.clearSession(coach.id);

    emit(ChatLoaded(messages: _messages));
  }

  /// Resume an existing chat session
  Future<void> loadSession(String sessionId, Coach coach) async {
    emit(ChatLoading());
    _currentCoach = coach;
    _currentSessionId = sessionId;

    try {
      final session = await localStorageService.getSession(sessionId);
      if (session != null) {
        _messages = List<ChatMessage>.from(session.messages);

        if (session.hasUnread) {
          await localStorageService.markSessionRead(sessionId);
        }

        // Clear previous AI session and create a new one with history
        aiService.clearSession(coach.id);
        aiService.getOrCreateSession(
          coachId: coach.id,
          remoteConfigKey: coach.remoteConfigKey,
          previousMessages: _messages,
        );

        emit(ChatLoaded(messages: _messages));
      } else {
        await startNewSession(coach);
      }
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  /// Send a message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _currentCoach == null || _currentSessionId == null) {
      return;
    }

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      sessionId: _currentSessionId!,
      content: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    final historyBeforeCurrentMessage = List<ChatMessage>.from(_messages);

    _messages = [..._messages, userMessage];
    emit(ChatLoaded(messages: _messages, isTyping: true));

    // Save user message
    await localStorageService.saveMessage(userMessage);

    final existingSession = await localStorageService.getSession(_currentSessionId!);

    // Persist session immediately so chat history always shows latest activity.
    final userSnapshot = models.ChatSession(
      id: _currentSessionId!,
      coachId: _currentCoach!.id,
      coachName: _currentCoach!.coachName,
      lastMessage: text.trim().length > 100
          ? '${text.trim().substring(0, 100)}...'
          : text.trim(),
      lastMessageTime: DateTime.now(),
      createdAt: existingSession?.createdAt ?? DateTime.now(),
      isArchived: existingSession?.isArchived ?? false,
      hasUnread: false,
    );
    await localStorageService.saveSession(userSnapshot);

    try {
      final response = await aiService.sendMessage(
        coachId: _currentCoach!.id,
        remoteConfigKey: _currentCoach!.remoteConfigKey,
        message: text.trim(),
        previousMessages: historyBeforeCurrentMessage,
      );

      final botMessage = ChatMessage(
        id: _uuid.v4(),
        sessionId: _currentSessionId!,
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages = [..._messages, botMessage];

      // Save bot message
      await localStorageService.saveMessage(botMessage);

      // Update session metadata
      final updatedSession = models.ChatSession(
        id: _currentSessionId!,
        coachId: _currentCoach!.id,
        coachName: _currentCoach!.coachName,
        lastMessage: response.length > 100
            ? '${response.substring(0, 100)}...'
            : response,
        lastMessageTime: DateTime.now(),
        createdAt: existingSession?.createdAt ?? DateTime.now(),
        isArchived: existingSession?.isArchived ?? false,
        hasUnread: true,
      );
      await localStorageService.saveSession(updatedSession);

      emit(ChatLoaded(messages: _messages, isTyping: false));
    } catch (e) {
      emit(ChatError(
        message: 'Failed to get response. ${e.toString()}',
        previousMessages: _messages,
      ));
    }
  }

  /// Retry after error
  void retryFromError() {
    if (state is ChatError) {
      final errorState = state as ChatError;
      _messages = List.from(errorState.previousMessages);
      emit(ChatLoaded(messages: _messages));
    }
  }

  @override
  Future<void> close() {
    if (_currentCoach != null) {
      aiService.clearSession(_currentCoach!.id);
    }
    return super.close();
  }
}
