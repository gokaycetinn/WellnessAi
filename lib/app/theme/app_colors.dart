import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF3C8F68);
  static const Color primaryDark = Color(0xFF2F7254);
  static const Color accent = Color(0xFF7BCFA5);

  // Backgrounds
  static const Color background = Color(0xFFF5F7F4);
  static const Color primarySurface = Color(0xFFE6F1EB);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1F2A37);
  static const Color textSecondary = Color(0xFF7A8797);
  static const Color textTertiary = Color(0xFFA0AEC0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Elements
  static const Color cardBorder = Color(0xFFEAECEF);
  static const Color divider = Color(0xFFEAECEF);
  static const Color shadowColor = Color.fromRGBO(0, 0, 0, 0.05);

  // Tints
  static const Color softGreenTint = Color(0xFFE6F1EB);
  static const Color softBlueTint = Color(0xFFEBF8FF);
  static const Color softLavenderTint = Color(0xFFF3E8FF);
  static const Color softPeachTint = Color(0xFFFFF5EB);

  // Chat
  static const Color userBubble = Color(0xFF3C8F68);
  static const Color botBubble = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFFFFFFF);

  // Status
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF3C8F68);
  static const Color warning = Color(0xFFFFA726);

  // Legacy (Keep for compatibility if used elsewhere, or map to new)
  static const Color white = Color(0xFFFFFFFF);
  static const Color primaryLight = Color(0xFF6FCF97); // Approximation
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF3C8F68), Color(0xFF56A27D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Specific Coach Colors (mapping old to new tints logic where needed)
  static const Color dietitianColor = Color(0xFF3C8F68);
  static const Color fitnessColor = Color(0xFF3B82F6);
  static const Color yogaColor = Color(0xFF8B5CF6);
  static const Color pilatesColor = Color(0xFFF97316);
}
