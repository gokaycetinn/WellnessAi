import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wellness_ai/app/theme/app_colors.dart';
import 'package:wellness_ai/app/theme/app_text_styles.dart';
import 'package:wellness_ai/core/models/coach.dart';
import 'package:wellness_ai/features/chat/cubit/chat_cubit.dart';
import 'package:wellness_ai/features/chat/cubit/chat_state.dart';
import 'widgets/message_bubble.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final Coach coach;

  const ChatScreen({super.key, required this.coach});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  Coach get coach => widget.coach;

  Color get _softCoachAccent =>
      Color.alphaBlend(Colors.white.withValues(alpha: 0.08), coach.color);

  Color get _softCoachSurface =>
      Color.alphaBlend(Colors.white.withValues(alpha: 0.32), coach.tintColor);

  List<String> _getQuickStartPrompts() {
    switch (coach.id) {
      case 'dietitian':
        return const [
          'What should I eat today?',
          'What is my daily calorie target?',
          'Create a simple weekly meal plan',
        ];
      case 'fitness_coach':
        return const [
          'Build a beginner weekly workout plan',
          'Give me a 30-minute no-equipment home workout',
          'What is the best routine for fat loss?',
        ];
      case 'pilates_coach':
        return const [
          'What is Pilates for beginners?',
          'Give me a 15-minute core-focused Pilates flow',
          'Which exercises improve posture?',
        ];
      case 'yoga_guru':
        return const [
          'Give me a short yoga flow for stress relief',
          'Create a beginner-friendly yoga routine',
          'Make a 20-minute flexibility plan',
        ];
      default:
        return const [
          'Give me a beginner starting plan',
          'Build a short routine for my goal',
          'Where should I start today?',
        ];
    }
  }

  void _sendQuickPrompt(String prompt) {
    context.read<ChatCubit>().sendMessage(prompt);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: coach.color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              // Messages list
              Expanded(
                child: BlocConsumer<ChatCubit, ChatState>(
                  listener: (context, state) {
                    if (state is ChatLoaded) {
                      _scrollToBottom();
                    }
                  },
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      );
                    }

                    if (state is ChatError) {
                      return _buildErrorView(context, state);
                    }

                    if (state is ChatLoaded) {
                      return _buildMessagesList(context, state);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
              // Input bar
              BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  final isTyping = state is ChatLoaded && state.isTyping;
                  return ChatInputBar(
                    onSend: (text) =>
                        context.read<ChatCubit>().sendMessage(text),
                    enabled: !isTyping,
                    accentColor: _softCoachAccent,
                    accentSurfaceColor: _softCoachSurface,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FCFA), AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border(
            bottom: BorderSide(color: AppColors.cardBorder),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          // Coach avatar
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: coach.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              coach.imagePath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coach.coachName,
                style: AppTextStyles.titleMedium,
              ),
              Text(
                'WellnessAI Guide',
                style: AppTextStyles.bodySmall.copyWith(
                  color: _softCoachAccent,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: const [],
    );
  }

  Widget _buildMessagesList(BuildContext context, ChatLoaded state) {
    if (state.messages.isEmpty && !state.isTyping) {
      return _buildEmptyChat();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: state.messages.length + (state.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.messages.length && state.isTyping) {
          return TypingIndicator(
            coachImagePath: coach.imagePath,
            coachColor: coach.color,
            coachTintColor: coach.tintColor,
          );
        }
        return MessageBubble(
          message: state.messages[index],
          coachImagePath: coach.imagePath,
          coachColor: _softCoachAccent,
          coachTintColor: _softCoachSurface,
        );
      },
    );
  }

  Widget _buildEmptyChat() {
    final quickPrompts = _getQuickStartPrompts();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: coach.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                coach.imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Start chatting with ${coach.coachName}',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              coach.title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Quick start',
              style: AppTextStyles.labelMedium.copyWith(
                color: _softCoachAccent,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: quickPrompts
                  .map(
                    (prompt) => InkWell(
                      onTap: () => _sendQuickPrompt(prompt),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _softCoachSurface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _softCoachAccent.withValues(alpha: 0.35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _softCoachAccent.withValues(alpha: 0.14),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          prompt,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: _softCoachAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, ChatError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ChatCubit>().retryFromError(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
