import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:wellness_ai/app/theme/app_colors.dart';
import 'package:wellness_ai/app/theme/app_text_styles.dart';
import 'package:wellness_ai/core/models/coach.dart';
import 'package:wellness_ai/core/services/ai_service.dart';
import 'package:wellness_ai/core/services/local_storage_service.dart';
import 'package:wellness_ai/features/chat/cubit/chat_cubit.dart';
import 'package:wellness_ai/features/chat/view/chat_screen.dart';
import 'package:wellness_ai/features/coaches/cubit/coaches_cubit.dart';
import 'package:wellness_ai/features/coaches/cubit/coaches_state.dart';
import 'widgets/coach_card.dart';

class CoachesScreen extends StatelessWidget {
  const CoachesScreen({super.key});

  void _navigateToChat(BuildContext context, Coach coach) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ChatCubit(
            aiService: context.read<AiService>(),
            localStorageService: context.read<LocalStorageService>(),
          )..startNewSession(coach),
          child: ChatScreen(coach: coach),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<CoachesCubit, CoachesState>(
        builder: (context, state) {
          if (state is CoachesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is CoachesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.warningCircle(),
                      size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('Something went wrong',
                      style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        context.read<CoachesCubit>().loadCoaches(),
                    child: Text('Retry', style: AppTextStyles.ctaText),
                  ),
                ],
              ),
            );
          }

          if (state is CoachesLoaded) {
            return _buildContent(context, state.coaches);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Coach> coaches) {
    final topInset = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final cardExtent = screenHeight < 760 ? 294.0 : 322.0;
    final bottomSpacing = bottomInset + 120;

    return Stack(
      children: [
        Positioned(
          top: -70,
          right: -50,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          top: 180,
          left: -70,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.08),
            ),
          ),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, topInset + 4, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Featured coaches', style: AppTextStyles.titleLarge),
                          const SizedBox(height: 4),
                          Text('Choose your coach', style: AppTextStyles.labelMedium),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 4,
                            children: [
                              _buildStatPill('${coaches.length} expert coaches'),
                              _buildStatPill('24/7 AI guidance'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Profile Button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Icon(
                        PhosphorIcons.user(),
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
            
            // Coaches Grid
            Transform.translate(
              offset: const Offset(0, -42),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 14,
                  mainAxisExtent: cardExtent,
                ),
                itemCount: coaches.length,
                itemBuilder: (context, index) {
                  return CoachCard(
                    coach: coaches[index],
                    onTap: () => _navigateToChat(context, coaches[index]),
                  );
                },
              ),
            ),

            SizedBox(height: bottomSpacing),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
