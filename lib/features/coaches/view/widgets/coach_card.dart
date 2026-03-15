import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wellness_ai/app/theme/app_colors.dart';
import 'package:wellness_ai/app/theme/app_text_styles.dart';
import 'package:wellness_ai/core/models/coach.dart';

class CoachCard extends StatefulWidget {
  final Coach coach;
  final VoidCallback onTap;

  const CoachCard({
    super.key,
    required this.coach,
    required this.onTap,
  });

  @override
  State<CoachCard> createState() => _CoachCardState();
}

class _CoachCardState extends State<CoachCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageSize = constraints.maxWidth * 0.8;

            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.surface, Color(0xFFF8FAF9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: imageSize,
                        height: imageSize,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: widget.coach.tintColor,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: SvgPicture.asset(
                          widget.coach.imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.coach.name,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 18, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.coach.title,
                      style: AppTextStyles.cardDescription.copyWith(fontSize: 14, height: 1.32),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Transform.translate(
                            offset: const Offset(0, -18),
                            child: Text(
                              widget.coach.actionLabel,
                              style: AppTextStyles.ctaText.copyWith(
                                fontWeight: FontWeight.w700,
                                color: widget.coach.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -18),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: widget.coach.color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: widget.coach.color,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
