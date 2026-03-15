import 'package:equatable/equatable.dart';

bool _parseIsUserValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

class ChatMessage extends Equatable {
  final String id;
  final String sessionId;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      sessionId: map['sessionId'] as String,
      content: map['content'] as String,
      isUser: _parseIsUserValue(map['isUser']),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  List<Object?> get props => [id, sessionId, content, isUser, timestamp];
}
