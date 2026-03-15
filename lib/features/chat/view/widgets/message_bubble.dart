import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wellness_ai/app/theme/app_colors.dart';
import 'package:wellness_ai/app/theme/app_text_styles.dart';
import 'package:wellness_ai/core/models/chat_message.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String coachImagePath;
  final Color coachColor;
  final Color coachTintColor;

  const MessageBubble({
    super.key,
    required this.message,
    required this.coachImagePath,
    required this.coachColor,
    required this.coachTintColor,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: coachColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: SvgPicture.asset(
                  coachImagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        isUser ? coachTintColor : AppColors.botBubble,
                    border: isUser
                        ? Border.all(
                            color: coachColor.withValues(alpha: 0.28),
                          )
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: AppTextStyles.chatMessage.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: AppTextStyles.chatTimestamp,
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 40),
        ],
      ),
    );
  }
}
