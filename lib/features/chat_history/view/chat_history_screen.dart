import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wellness_ai/app/theme/app_colors.dart';
import 'package:wellness_ai/app/theme/app_text_styles.dart';
import 'package:wellness_ai/core/constants/app_constants.dart';
import 'package:wellness_ai/core/models/coach.dart';
import 'package:wellness_ai/core/models/chat_session.dart';
import 'package:wellness_ai/core/services/ai_service.dart';
import 'package:wellness_ai/core/services/local_storage_service.dart';
import 'package:wellness_ai/features/chat/cubit/chat_cubit.dart';
import 'package:wellness_ai/features/chat/view/chat_screen.dart';
import 'package:wellness_ai/features/chat_history/cubit/chat_history_cubit.dart';
import 'package:wellness_ai/features/chat_history/cubit/chat_history_state.dart';
import 'widgets/chat_history_tile.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => ChatHistoryScreenState();
}

class ChatHistoryScreenState extends State<ChatHistoryScreen> {
  int _selectedTab = 0;

  static const int _allTab = 0;
  static const int _unreadTab = 1;
  static const int _archivedTab = 2;

  @override
  void initState() {
    super.initState();
    context.read<ChatHistoryCubit>().loadHistory();
  }

  void refreshHistory() {
    if (!mounted) return;
    context.read<ChatHistoryCubit>().loadHistory();
  }

  Coach _getCoachById(String coachId) {
    final data = AppConstants.coachData.firstWhere(
      (d) => d['id'] == coachId,
      orElse: () => AppConstants.coachData.first,
    );
    return Coach.fromMap(data);
  }

  void _navigateToChatSession(String sessionId, String coachId) {
    final coach = _getCoachById(coachId);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ChatCubit(
            aiService: context.read<AiService>(),
            localStorageService: context.read<LocalStorageService>(),
          )..loadSession(sessionId, coach),
          child: ChatScreen(coach: coach),
        ),
      ),
    )
        .then((_) {
      if (!mounted) return;
      // Refresh history when returning
      context.read<ChatHistoryCubit>().loadHistory();
    });
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete conversation?'),
        content: const Text('This will permanently remove the chat history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  List<ChatSession> _filterSessions(ChatHistoryLoaded state) {
    switch (_selectedTab) {
      case _unreadTab:
        return state.sessions
            .where((session) => !session.isArchived && session.hasUnread)
            .toList();
      case _archivedTab:
        return state.sessions.where((session) => session.isArchived).toList();
      case _allTab:
      default:
        return state.sessions.where((session) => !session.isArchived).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: BlocBuilder<ChatHistoryCubit, ChatHistoryState>(
                builder: (context, state) {
                  if (state is ChatHistoryLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    );
                  }

                  if (state is ChatHistoryError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: 16),
                          Text('Something went wrong',
                              style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context
                                .read<ChatHistoryCubit>()
                                .loadHistory(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ChatHistoryLoaded) {
                    final filteredSessions = _filterSessions(state);
                    if (filteredSessions.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildSessionsList(filteredSessions);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFFEAF5EF), Color(0xFFF7FBF9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Chat History',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['All Messages', 'Unread', 'Archived'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == _selectedTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              margin: EdgeInsets.only(right: index < tabs.length - 1 ? 8 : 0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.cardBorder,
                  width: 1,
                ),
              ),
              child: Text(
                tabs[index],
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        }),
        ),
      ),
    );
  }

  Widget _buildSessionsList(List<ChatSession> sessions) {
    final isArchiveTab = _selectedTab == _archivedTab;

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ChatHistoryCubit>().loadHistory();
      },
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: sessions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final session = sessions[index];
          return ChatHistoryTile(
            session: session,
            isUnread: session.hasUnread,
            archiveMode: isArchiveTab,
            onTap: () =>
                _navigateToChatSession(session.id, session.coachId),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                if (isArchiveTab) {
                  await context.read<ChatHistoryCubit>().unarchiveSession(session.id);
                } else {
                  await context.read<ChatHistoryCubit>().archiveSession(session.id);
                }
                return true;
              }

              final shouldDelete = await _confirmDelete(context);
              if (!shouldDelete) {
                return false;
              }
              if (!context.mounted) return false;
              await context.read<ChatHistoryCubit>().deleteSession(session.id);
              return true;
            },
            onDismissed: (_) {},
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final String title;
    final String subtitle;

    if (_selectedTab == _archivedTab) {
      title = 'No archived conversations';
      subtitle = 'Swipe right to restore chats or swipe left to delete.';
    } else if (_selectedTab == _unreadTab) {
      title = 'No unread messages';
      subtitle = 'You are all caught up. New replies will appear here.';
    } else {
      title = 'No conversations yet';
      subtitle =
          'Start chatting with a coach to see your conversation history here.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
