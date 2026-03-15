import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:wellness_ai/core/models/chat_message.dart';
import 'package:wellness_ai/core/services/firebase_service.dart';

class AiService {
  final FirebaseService firebaseService;
  final Map<String, AiChatSession> _activeSessions = {};
  static const List<String> _modelCandidates = [
    'gemini-2.0-flash',
    'gemini-2.0-flash-001',
    'gemini-2.5-flash',
    'gemini-1.5-flash',
    'gemini-1.5-flash-002',
  ];

  AiService({required this.firebaseService});

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll('`', "'")
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ş', 's')
        .replaceAll('ç', 'c')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .trim();
  }

        String _sanitizeOutput(String text) {
          return text
          .replaceAll('**', '')
          .replaceAll('__', '')
          .trim();
        }

        bool _wantsDetailedResponse(String message) {
          final input = _normalize(message);
          return _containsAny(input, [
            'detailed',
            'detail',
            'step by step',
            'full plan',
            'complete plan',
            'ayrintili',
            'detayli',
            'tum plan',
            'tam plan',
          ]);
        }

        String _postProcessResponse({
          required String rawResponse,
          required String userMessage,
        }) {
          final sanitized = _sanitizeOutput(rawResponse);
          if (sanitized.isEmpty) return sanitized;

          final lines = sanitized.split('\n').where((l) => l.trim().isNotEmpty).length;
          final isLong = sanitized.length > 420 || lines > 8;

          if (!isLong) return sanitized;

          final wantsDetailed = _wantsDetailedResponse(userMessage);

          if (wantsDetailed) {
            if (sanitized.length <= 700) {
              return sanitized;
            }

            final chunk = sanitized.substring(0, 700).trimRight();
            return '$chunk\n\nI can continue with part 2 if you want.';
          }

          final sentenceParts = sanitized.split(RegExp(r'(?<=[.!?])\s+'));
          final concise = <String>[];
          for (final part in sentenceParts) {
            if (part.trim().isEmpty) continue;
            concise.add(part.trim());
            if (concise.length >= 3) break;
          }

          var shortResponse = concise.join(' ');
          if (shortResponse.isEmpty) {
            shortResponse = sanitized.substring(0, sanitized.length > 320 ? 320 : sanitized.length);
          }

          if (shortResponse.length > 360) {
            shortResponse = '${shortResponse.substring(0, 360).trimRight()}...';
          }

          return '$shortResponse\n\nWould you like me to continue with the next part?';
        }

  bool _containsAny(String input, List<String> patterns) {
    for (final pattern in patterns) {
      if (input.contains(pattern)) return true;
    }
    return false;
  }

  bool _looksTurkish(String input) {
    return _containsAny(input, [
      'turkce',
      'nedir',
      'ne',
      'hafta',
      'program',
      'var mi',
      'begenmedim',
      'sevmedim',
    ]);
  }

  String _chooseVariant(String seed, List<String> options) {
    if (options.isEmpty) return '';
    final index = seed.hashCode.abs() % options.length;
    return options[index];
  }

  GenerativeModel _createModel({
    required String modelName,
    required String remoteConfigKey,
  }) {
    final baseInstruction =
        firebaseService.getSystemInstruction(remoteConfigKey);
    final systemInstruction = '''
$baseInstruction

Conversation rules:
- Always respond to the user's latest message directly.
- Do not repeat the same onboarding question list on every turn.
- Keep replies concise, practical, and adaptive to prior context.
  - Always respond in English.
- If the user rejects a suggestion, propose an alternative instead of repeating.
- Default to short answers (about 4-7 lines max) unless user explicitly asks for detailed output.
- For long topics, provide part 1 first and ask whether to continue.
''';

    return FirebaseAI.googleAI().generativeModel(
      model: modelName,
      systemInstruction: Content.system(systemInstruction),
    );
  }

  List<Content> _buildHistory(List<ChatMessage>? previousMessages) {
    final history = <Content>[];
    if (previousMessages != null) {
      for (final msg in previousMessages) {
        if (msg.isUser) {
          history.add(Content('user', [TextPart(msg.content)]));
        } else {
          history.add(Content('model', [TextPart(msg.content)]));
        }
      }
    }
    return history;
  }

  AiChatSession _createSession({
    required String coachId,
    required String remoteConfigKey,
    required String modelName,
    List<ChatMessage>? previousMessages,
  }) {
    final model = _createModel(
      modelName: modelName,
      remoteConfigKey: remoteConfigKey,
    );

    final chat = model.startChat(history: _buildHistory(previousMessages));
    return AiChatSession(
      chat: chat,
      coachId: coachId,
      modelName: modelName,
      remoteConfigKey: remoteConfigKey,
    );
  }

  /// Start or resume a chat session with a given coach.
  /// [coachId] identifies the coach.
  /// [remoteConfigKey] is used to fetch the system instruction.
  /// [previousMessages] are messages from a resumed session.
  AiChatSession getOrCreateSession({
    required String coachId,
    required String remoteConfigKey,
    List<ChatMessage>? previousMessages,
  }) {
    // If we already have an active session for this coach interaction, return it
    if (_activeSessions.containsKey(coachId)) {
      return _activeSessions[coachId]!;
    }

    final session = _createSession(
      coachId: coachId,
      remoteConfigKey: remoteConfigKey,
      modelName: _modelCandidates.first,
      previousMessages: previousMessages,
    );
    _activeSessions[coachId] = session;
    return session;
  }

  String _fallbackReply({
    required String coachId,
    required String message,
  }) {
    final input = _normalize(message);
    final isNegative = _containsAny(input, [
      "don't",
      'dont',
      'dislike',
      'not like',
      'begenmedim',
      'sevmedim',
      'hosuma gitmedi',
    ]);
    final asksPlan = _containsAny(input, [
      'plan',
      'program',
      'routine',
      'hafta',
      'weekly',
      'week',
    ]);
    final asksDefinition = _containsAny(input, [
      'nedir',
      'ne demek',
      'what is',
      'acikla',
    ]);
    final isGreeting = _containsAny(input, ['hi', 'hello', 'selam', 'merhaba']);
    final preferTurkish = _looksTurkish(input);

    final userTopic = message.trim().isEmpty ? 'your goal' : '"${message.trim()}"';

    if (coachId == 'dietitian') {
      if (preferTurkish) {
        if (isNegative) {
          return 'Anladim, bu tarzi begenmedin. Damak tadina uygun hale getirelim: sevdigin 3 yiyecegi ve hedefini yaz, sana daha uygun bir beslenme plani vereyim.';
        }
        if (asksDefinition) {
          return 'Diyetisyen destegi; dengeli ogun, porsiyon kontrolu, protein-lif dengesi ve surdurulebilir aliskanliklar kurmaya odaklanir. Istersen bugune ozel ornek bir menuyu hemen hazirlayayim.';
        }
        if (asksPlan) {
          return 'Haftalik baslangic plani: gunde 3 ana ogun + 1 ara ogun; her ogunde protein + sebze + kaliteli karbonhidrat olsun. Istersen bunu 7 gunluk detayli menuye cevirebilirim.';
        }
        if (isGreeting) {
          return 'Merhaba. Hedefine gore net bir beslenme plani yapabiliriz. Kilo verme, koruma veya kas kazanimi hedeflerinden hangisine odaklaniyorsun?';
        }
        return _chooseVariant(message, [
          'Mesajin "$message" icin pratik bir adim: her ogunde protein kaynagi ekle ve gunluk su tuketimini duzenli takip et. Istersen bunu saat saat plana dokeyim.',
          'Bu konuda en hizli iyilestirme: duzenli ogun saati + porsiyon takibi + sebze agirlikli tabak duzeni. Istersen buna uygun 3 gunluk plan yazayim.',
          'Sana uygun bir beslenme sistemi kurabiliriz. Hedefin ve gunluk rutinin neyse ona gore sade bir plan cikarayim.',
        ]);
      }

      if (isNegative) {
        return 'Understood about $userTopic. Let\'s adjust your nutrition plan to your taste: tell me 3 foods you enjoy, your meal schedule, and your main goal (fat loss, maintenance, muscle gain), and I will tailor a better option.';
      }
      if (asksDefinition) {
        return 'For $userTopic: dietitian support means practical nutrition coaching with balanced meals, portions, protein/fiber targets, and hydration habits. I can create a one-day example menu if you want.';
      }
      if (asksPlan) {
        return 'Based on $userTopic, start with 3 meals + 1 snack daily: each meal should include protein, vegetables, and quality carbs. Keep hydration around 2-2.5L/day. I can produce a full 7-day menu for your routine.';
      }
      return 'Thanks for sharing $userTopic. A solid nutrition baseline is: half vegetables, quarter protein, quarter whole grains, plus steady hydration. If you share your daily schedule, I will tailor a specific meal plan.';
    }
    if (coachId == 'fitness_coach') {
      if (preferTurkish) {
        if (isNegative) {
          return 'Tamam, yaklasimi degistirelim. Evde mi salonda mi calismak istiyorsun ve haftada kac gun ayirabilirsin? Buna gore programi yenileyeyim.';
        }
        if (asksDefinition) {
          return 'Fitness koclugu; guc, kondisyon, mobilite ve guvenli progresif gelisime odaklanir. Duzenli takip ile haftalik performansi artirir.';
        }
        if (asksPlan) {
          return 'Baslangic haftalik plan: 3 antrenman gunu (tum vucut), 2 hafif aktivite gunu. Her antrenman 40-50 dk, hareket kalitesine odakli olsun.';
        }
        if (isGreeting) {
          return 'Selam. Sana uygun bir antrenman plani yazabilirim. Seviye, ekipman ve haftalik zamanini yazarsan hemen baslayalim.';
        }
        return _chooseVariant(message, [
          'Mesajin "$message" icin en iyi adim: olculebilir bir hedef belirleyip 3 gunluk tum vucut programina baslamak.',
          'Bu konu icin once sakatlik riski olmadan temel hareket kalibini kurup sonra yogunlugu artirmak en dogrusu.',
          'Istersen bunu seviyene gore set-tekrar-dinlenme detaylariyla planlayayim.',
        ]);
      }

      if (isNegative) {
        return 'Got it about $userTopic. We can switch approach. Tell me if you prefer home, gym, or bodyweight only, and how many days you can train, then I will redesign the plan.';
      }
      if (asksDefinition) {
        return 'For $userTopic: fitness coaching combines strength, cardio, mobility, and progressive overload with safe form. A good start is 3 training days plus 2 light activity days.';
      }
      if (asksPlan) {
        return 'Based on $userTopic, starter weekly plan: Day 1 full-body strength, Day 2 cardio intervals, Day 3 full-body + core. Keep sessions 40-50 minutes and progress load gradually.';
      }
      return 'Thanks for your message about $userTopic. Start with 3 full-body sessions this week focused on squat, push, hinge, pull, and core. I can break this into a day-by-day plan for your level.';
    }
    if (coachId == 'pilates_coach') {
      if (preferTurkish) {
        if (isNegative) {
          return 'Anladim, daha hafif bir akisa gecelim. 10 dakikalik baslangic seviyesinde, daha az zorlayici bir plan ister misin?';
        }
        if (asksDefinition) {
          return 'Pilates; core kontrolu, postur, nefes ve yavas-kontrollu hareket kalitesine odaklanan dusuk etkili bir egzersiz sistemidir.';
        }
        if (asksPlan) {
          return 'Baslangic pilates plani: haftada 3 gun, 15-20 dk. Sira: nefes hazirligi, pelvic curl, dead bug, yan bacak serisi, spine stretch.';
        }
        if (isGreeting) {
          return 'Merhaba. Pilates icin hedefini yazarsan (postur, core, esneklik) sana uygun kisa bir akisi hemen olusturabilirim.';
        }
        return _chooseVariant(message, [
          'Bu mesajin icin once nefes + core aktivasyonu ile baslamak en saglikli adim olur.',
          'Istersen bunu baslangic/orta seviyeye gore adim adim bicimde duzenleyebilirim.',
          'Sana uygun tempo ve tekrarlarla guvenli bir pilates akisi yazabilirim.',
        ]);
      }

      if (isNegative) {
        return 'I hear you regarding $userTopic. We can make it shorter and gentler. If you want, I can switch to a 10-minute beginner flow with lower intensity and more mobility.';
      }
      if (asksDefinition) {
        return 'For $userTopic: Pilates is controlled, low-impact movement training for core stability, posture, alignment, and breath control. It builds strength with mindful execution.';
      }
      if (asksPlan) {
        return 'Based on $userTopic, simple Pilates plan: 3 days/week, 15-20 minutes. Sequence: breathing prep, pelvic curl, dead bug, side leg series, spine stretch. Increase control time weekly.';
      }
      return 'Thanks for sharing $userTopic. Try a focused 15-minute flow: breathing prep, pelvic curl, dead bug, side leg series, and spine stretch. I can adapt it to beginner or intermediate level.';
    }
    if (coachId == 'yoga_guru') {
      if (preferTurkish) {
        if (isNegative) {
          return 'Geri bildirimin icin tesekkurler. Daha sakin bir akis mi yoksa biraz daha guclu bir akis mi istersin? Tercihine gore duzenleyeyim.';
        }
        if (asksDefinition) {
          return 'Yoga; nefes, mobilite, denge ve farkindaligi birlestiren bir pratik. Duzenli yapildiginda hem beden hem zihin tarafinda fayda saglar.';
        }
        if (asksPlan) {
          return 'Baslangic yoga plani: haftada 4 gun, 15-25 dk. Kedi-inek, downward dog, low lunge, twist ve child pose sirasi iyi bir temel olur.';
        }
        if (isGreeting) {
          return 'Selam. Istersen sana bugun icin 12 dakikalik sakinlestirici bir yoga akisi hazirlayayim.';
        }
        return _chooseVariant(message, [
          'Bu konu icin nefes odakli kisa bir yoga akisi iyi bir baslangic olur.',
          'Istersen seviyene gore poz surelerini ve modifikasyonlari da ekleyebilirim.',
          'Sana uygun bir denge-esneklik odakli mini program olusturabilirim.',
        ]);
      }

      if (isNegative) {
        return 'Thanks for the feedback on $userTopic. Let\'s switch style: calmer stress-relief flow or stronger mobility flow. I can tailor it to your preference.';
      }
      if (asksDefinition) {
        return 'For $userTopic: yoga coaching combines breathing, mobility, flexibility, and mindful movement. Short consistent sessions improve posture, stress management, and balance.';
      }
      if (asksPlan) {
        return 'Based on $userTopic, starter yoga routine: 4 sessions/week for 15-25 minutes. Include cat-cow, downward dog, low lunge, spinal twist, and child\'s pose with slow breathing.';
      }
      return 'Thanks for your message about $userTopic. A short calming sequence can include cat-cow, downward dog, low lunge, seated twist, and child\'s pose. I can build a custom 20-minute flow for your goal.';
    }
    return 'Thanks for sharing $userTopic. I can help with a practical wellness plan. Tell me your goal, available time, and current level, and I will suggest the best next steps.';
  }

  /// Send a message and get a response.
  Future<String> sendMessage({
    required String coachId,
    required String remoteConfigKey,
    required String message,
    List<ChatMessage>? previousMessages,
  }) async {
    final attemptedModels = <String>[];

    try {
      final session = getOrCreateSession(
        coachId: coachId,
        remoteConfigKey: remoteConfigKey,
        previousMessages: previousMessages,
      );
      attemptedModels.add(session.modelName);

      final response = await session.chat.sendMessage(
        Content('user', [TextPart(message)]),
      );

      if (response.text != null && response.text!.trim().isNotEmpty) {
        return _postProcessResponse(
          rawResponse: response.text!,
          userMessage: message,
        );
      }
    } catch (e) {
      debugPrint('Primary AI send failed for $coachId: $e');
    }

    for (final modelName in _modelCandidates) {
      if (attemptedModels.contains(modelName)) continue;

      try {
        final retrySession = _createSession(
          coachId: coachId,
          remoteConfigKey: remoteConfigKey,
          modelName: modelName,
          previousMessages: previousMessages,
        );
        _activeSessions[coachId] = retrySession;

        final response = await retrySession.chat.sendMessage(
          Content('user', [TextPart(message)]),
        );
        if (response.text != null && response.text!.trim().isNotEmpty) {
          return _postProcessResponse(
            rawResponse: response.text!,
            userMessage: message,
          );
        }
      } catch (e) {
        debugPrint('Retry AI send failed for $coachId on $modelName: $e');
      }
    }

    return _postProcessResponse(
      rawResponse: _fallbackReply(coachId: coachId, message: message),
      userMessage: message,
    );
  }

  /// Clear session when navigating away
  void clearSession(String coachId) {
    _activeSessions.remove(coachId);
  }

  /// Clear all sessions
  void clearAllSessions() {
    _activeSessions.clear();
  }
}

/// Wraps a Firebase AI chat session
class AiChatSession {
  final ChatSession chat;
  final String coachId;
  final String modelName;
  final String remoteConfigKey;

  AiChatSession({
    required this.chat,
    required this.coachId,
    required this.modelName,
    required this.remoteConfigKey,
  });
}
