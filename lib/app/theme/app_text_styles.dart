import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // App Title
  static TextStyle get appTitle => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // Main Heading
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  // Section Text
  static TextStyle get sectionHeading => GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // Card Title
  static TextStyle get cardTitle => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // Card Description
  static TextStyle get cardDescription => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // CTA Text
  static TextStyle get ctaText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  // Legacy mappings for compatibility
  static TextStyle get displayMedium => displayLarge.copyWith(fontSize: 28);
  
  static TextStyle get headlineLarge => appTitle;

  static TextStyle get headlineMedium => titleLarge;

  static TextStyle get titleLarge => cardTitle;
  
  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => cardDescription;

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      );

  static TextStyle get labelLarge => ctaText;

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // Missing properties (added for compatibility)
  static TextStyle get buttonText => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get chatMessage => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get chatTimestamp => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );
}

