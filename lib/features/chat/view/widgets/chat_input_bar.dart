import 'package:flutter/material.dart';
import 'package:wellness_ai/app/theme/app_colors.dart';
import 'package:wellness_ai/app/theme/app_text_styles.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String) onSend;
  final bool enabled;
  final Color accentColor;
  final Color accentSurfaceColor;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.accentColor = AppColors.primary,
    this.accentSurfaceColor = AppColors.primarySurface,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && widget.enabled) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Attachment button
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: widget.accentSurfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: widget.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                // Text field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: widget.enabled,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 4,
                    minLines: 1,
                    style: AppTextStyles.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Message WellnessAI...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 10),
                // Send button
                GestureDetector(
                  onTap: _handleSend,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color:
                          _hasText ? widget.accentColor : widget.accentSurfaceColor,
                      shape: BoxShape.circle,
                      boxShadow: _hasText
                          ? [
                              BoxShadow(
                                color:
                                    widget.accentColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color:
                          _hasText ? Colors.white : widget.accentColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Personalized guidance powered by WellnessAI',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
