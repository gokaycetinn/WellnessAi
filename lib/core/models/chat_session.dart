import 'package:equatable/equatable.dart';
import 'chat_message.dart';

bool _parseBoolValue(dynamic value, {required bool fallback}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
  }
  return fallback;
}

class ChatSession extends Equatable {
  final String id;
  final String coachId;
  final String coachName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final DateTime createdAt;
  final bool isArchived;
  final bool hasUnread;
  final List<ChatMessage> messages;

  const ChatSession({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
    this.isArchived = false,
    this.hasUnread = false,
    this.messages = const [],
  });

  ChatSession copyWith({
    String? id,
    String? coachId,
    String? coachName,
    String? lastMessage,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    bool? isArchived,
    bool? hasUnread,
    List<ChatMessage>? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      coachName: coachName ?? this.coachName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      hasUnread: hasUnread ?? this.hasUnread,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'coachId': coachId,
      'coachName': coachName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
      'hasUnread': hasUnread,
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map, {List<ChatMessage>? messages}) {
    return ChatSession(
      id: map['id'] as String,
      coachId: map['coachId'] as String,
      coachName: map['coachName'] as String,
      lastMessage: map['lastMessage'] as String,
      lastMessageTime: DateTime.parse(map['lastMessageTime'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isArchived: _parseBoolValue(map['isArchived'], fallback: false),
      hasUnread: _parseBoolValue(map['hasUnread'], fallback: false),
      messages: messages ?? const [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        coachId,
        coachName,
        lastMessage,
        lastMessageTime,
        createdAt,
        isArchived,
        hasUnread,
        messages,
      ];
}
