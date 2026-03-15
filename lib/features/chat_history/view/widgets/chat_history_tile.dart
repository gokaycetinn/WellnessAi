import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wellness_ai/app/theme/app_colors.dart';
import 'package:wellness_ai/app/theme/app_text_styles.dart';
import 'package:wellness_ai/core/constants/app_constants.dart';
import 'package:wellness_ai/core/models/chat_session.dart';
import 'package:intl/intl.dart';

class ChatHistoryTile extends StatelessWidget {
  final ChatSession session;
  final VoidCallback onTap;
  final ValueChanged<DismissDirection>? onDismissed;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;
  final bool isUnread;
  final bool archiveMode;

  const ChatHistoryTile({
    super.key,
    required this.session,
    required this.onTap,
    this.onDismissed,
    this.confirmDismiss,
    this.isUnread = false,
    this.archiveMode = false,
  });

  String _getCoachImage(String coachId) {
    final data = AppConstants.coachData.firstWhere(
      (d) => d['id'] == coachId,
      orElse: () => AppConstants.coachData.first,
    );
    return data['imagePath'] as String;
  }

  Color _getCoachTint(String coachId) {
    final data = AppConstants.coachData.firstWhere(
      (d) => d['id'] == coachId,
      orElse: () => AppConstants.coachData.first,
    );
    return data['tintColor'] ?? AppColors.softGreenTint;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEE').format(dateTime);
    return DateFormat('MMM d').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _getCoachImage(session.coachId);
    final tint = _getCoachTint(session.coachId);
    final archiveColor = archiveMode ? AppColors.warning : AppColors.primary;

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: confirmDismiss,
      onDismissed: (direction) => onDismissed?.call(direction),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
          color: archiveColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          archiveMode ? Icons.unarchive_rounded : Icons.archive_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.surface,
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Coach avatar
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tint,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          session.coachName,
                          style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatTime(session.lastMessageTime),
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.lastMessage.isNotEmpty
                                ? session.lastMessage
                                : 'Start a conversation...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
