import 'package:equatable/equatable.dart';
import 'package:wellness_ai/core/models/chat_session.dart';

abstract class ChatHistoryState extends Equatable {
  const ChatHistoryState();

  @override
  List<Object?> get props => [];
}

class ChatHistoryInitial extends ChatHistoryState {}

class ChatHistoryLoading extends ChatHistoryState {}

class ChatHistoryLoaded extends ChatHistoryState {
  final List<ChatSession> sessions;

  const ChatHistoryLoaded({required this.sessions});

  bool get isEmpty => sessions.isEmpty;

  @override
  List<Object?> get props => [sessions];
}

class ChatHistoryError extends ChatHistoryState {
  final String message;

  const ChatHistoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
