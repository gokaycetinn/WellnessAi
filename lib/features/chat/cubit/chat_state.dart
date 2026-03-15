import 'package:equatable/equatable.dart';
import 'package:wellness_ai/core/models/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;

  const ChatLoaded({
    required this.messages,
    this.isTyping = false,
  });

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  @override
  List<Object?> get props => [messages, isTyping];
}

class ChatError extends ChatState {
  final String message;
  final List<ChatMessage> previousMessages;

  const ChatError({
    required this.message,
    this.previousMessages = const [],
  });

  @override
  List<Object?> get props => [message, previousMessages];
}
