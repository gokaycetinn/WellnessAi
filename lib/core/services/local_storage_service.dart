import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:wellness_ai/core/constants/app_constants.dart';
import 'package:wellness_ai/core/models/chat_message.dart';
import 'package:wellness_ai/core/models/chat_session.dart' as models;

class LocalStorageService {
  late Box<String> _sessionsBox;
  late Box<String> _messagesBox;

  Future<void> init() async {
    _sessionsBox = await Hive.openBox<String>(AppConstants.sessionsBox);
    _messagesBox = await Hive.openBox<String>(AppConstants.messagesBox);
  }

  // ---- Sessions ----

  Future<void> saveSession(models.ChatSession session) async {
    final json = jsonEncode(session.toMap());
    await _sessionsBox.put(session.id, json);
  }

  Future<models.ChatSession?> getSession(String sessionId) async {
    final json = _sessionsBox.get(sessionId);
    if (json == null) return null;

    final map = jsonDecode(json) as Map<String, dynamic>;
    final messages = await getMessagesForSession(sessionId);
    return models.ChatSession.fromMap(map, messages: messages);
  }

  Future<List<models.ChatSession>> getAllSessions() async {
    final sessions = <models.ChatSession>[];
    for (final key in _sessionsBox.keys) {
      final json = _sessionsBox.get(key);
      if (json != null) {
        try {
          final map = jsonDecode(json) as Map<String, dynamic>;
          sessions.add(models.ChatSession.fromMap(map));
        } catch (_) {
          // Ignore malformed historical records so history UI can still render.
        }
      }
    }

    // Hide legacy empty sessions created before first message was sent.
    sessions.removeWhere((session) => session.lastMessage.trim().isEmpty);

    // Sort by most recent
    sessions.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return sessions;
  }

  Future<void> deleteSession(String sessionId) async {
    await _sessionsBox.delete(sessionId);
    // Also delete all messages for this session
    final keysToRemove = <String>[];
    for (final key in _messagesBox.keys) {
      final json = _messagesBox.get(key);
      if (json != null) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        if (map['sessionId'] == sessionId) {
          keysToRemove.add(key as String);
        }
      }
    }
    for (final key in keysToRemove) {
      await _messagesBox.delete(key);
    }
  }

  Future<void> archiveSession(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) return;
    await saveSession(session.copyWith(isArchived: true));
  }

  Future<void> unarchiveSession(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) return;
    await saveSession(session.copyWith(isArchived: false));
  }

  Future<void> markSessionRead(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) return;
    await saveSession(session.copyWith(hasUnread: false));
  }

  // ---- Messages ----

  Future<void> saveMessage(ChatMessage message) async {
    final json = jsonEncode(message.toMap());
    await _messagesBox.put(message.id, json);
  }

  Future<List<ChatMessage>> getMessagesForSession(String sessionId) async {
    final messages = <ChatMessage>[];
    for (final key in _messagesBox.keys) {
      final json = _messagesBox.get(key);
      if (json != null) {
        try {
          final map = jsonDecode(json) as Map<String, dynamic>;
          if (map['sessionId'] == sessionId) {
            messages.add(ChatMessage.fromMap(map));
          }
        } catch (_) {
          // Ignore malformed historical records.
        }
      }
    }
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  // ---- Utility ----

  Future<void> clearAll() async {
    await _sessionsBox.clear();
    await _messagesBox.clear();
  }
}
