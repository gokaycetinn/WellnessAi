import 'package:flutter/material.dart';
import 'package:wellness_ai/app/theme/app_colors.dart';
import 'package:wellness_ai/app/theme/app_text_styles.dart';

class WeeklyChallengeCard extends StatelessWidget {
  const WeeklyChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🏆 Weekly Challenge',
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Join the 15-minute mindfulness\nsession today.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // CTA Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'JOIN NOW',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.primaryDark,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
