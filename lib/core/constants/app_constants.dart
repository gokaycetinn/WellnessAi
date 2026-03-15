import 'package:flutter/material.dart';
import 'package:wellness_ai/app/theme/app_colors.dart';

class AppConstants {
  AppConstants._();

  // Remote Config keys
  static const String dietitianKey = 'dietitian_system_instruction';
  static const String fitnessCoachKey = 'fitness_coach_system_instruction';
  static const String pilatesCoachKey = 'pilates_coach_system_instruction';
  static const String yogaGuruKey = 'yoga_guru_system_instruction';

  // Default system instructions (fallbacks)
  static const Map<String, String> defaultSystemInstructions = {
    dietitianKey:
      'You are a professional Dietitian AI assistant. '
            'You specialize in meal planning, nutrition advice, and dietary guidance. '
            'Provide evidence-based nutritional recommendations. '
            'Be warm, encouraging, and supportive. '
            'Always remind users to consult with their healthcare provider for specific medical dietary needs. '
            'Keep responses concise and actionable.',
    fitnessCoachKey:
      'You are a professional Fitness Coach AI assistant. '
            'You specialize in strength training, cardio workouts, and overall fitness planning. '
            'Provide safe, effective exercise recommendations suitable for various fitness levels. '
            'Be motivating and energetic in your responses. '
            'Always emphasize proper form and safety. '
            'Keep responses concise and actionable.',
    pilatesCoachKey:
      'You are a professional Pilates Instructor AI assistant. '
            'You specialize in core strengthening, posture alignment, and Pilates techniques. '
            'Provide detailed movement instructions focusing on breath control and body awareness. '
            'Be calm, precise, and encouraging. '
            'Emphasize the mind-body connection in your guidance. '
            'Keep responses concise and actionable.',
    yogaGuruKey:
      'You are a professional Yoga Instructor AI assistant. '
            'You specialize in mindfulness, yoga flows, flexibility training, and breathing exercises. '
            'Guide users through poses with clear alignment cues and modifications for different levels. '
            'Be peaceful, compassionate, and wise. '
            'Incorporate mindfulness and meditation practices in your guidance. '
            'Keep responses concise and actionable.',
  };

  // Coach data
  static List<Map<String, dynamic>> coachData = [
    {
      'id': 'dietitian',
      'name': 'Dietitian',
      'coachName': 'Dietitian',
      'title': 'Nutrition & meal planning guidance',
      'actionLabel': 'Start plan',
      'icon': Icons.restaurant_menu_rounded,
      'imagePath': 'asset/dietician.svg',
      'color': AppColors.dietitianColor,
      'tintColor': AppColors.softGreenTint,
      'remoteConfigKey': dietitianKey,
    },
    {
      'id': 'fitness_coach',
      'name': 'Fitness Coach',
      'coachName': 'Fitness Coach',
      'title': 'Strength & cardio guidance',
      'actionLabel': 'Start training',
      'icon': Icons.fitness_center_rounded,
      'imagePath': 'asset/fitness.svg',
      'color': AppColors.fitnessColor,
      'tintColor': AppColors.softBlueTint,
      'remoteConfigKey': fitnessCoachKey,
    },
    {
      'id': 'yoga_guru',
      'name': 'Yoga Instructor',
      'coachName': 'Yoga Instructor',
      'title': 'Flexibility & mindfulness practice',
      'actionLabel': 'Start flow',
      'icon': Icons.self_improvement_rounded,
      'imagePath': 'asset/yoga.svg',
      'color': AppColors.yogaColor,
      'tintColor': AppColors.softLavenderTint,
      'remoteConfigKey': yogaGuruKey,
    },
    {
      'id': 'pilates_coach',
      'name': 'Pilates Coach',
      'coachName': 'Pilates Coach',
      'title': 'Core strength & posture support',
      'actionLabel': 'Start session',
      'icon': Icons.accessibility_new_rounded,
      'imagePath': 'asset/pilates.svg',
      'color': AppColors.pilatesColor,
      'tintColor': AppColors.softPeachTint,
      'remoteConfigKey': pilatesCoachKey,
    },
  ];

  // Hive box names
  static const String sessionsBox = 'chat_sessions';
  static const String messagesBox = 'chat_messages';
}
