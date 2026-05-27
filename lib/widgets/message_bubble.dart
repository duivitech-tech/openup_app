// lib/widgets/message_bubble.dart

import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../themes/app_theme.dart';

/// Chat message bubble with slide-in animation.
/// User messages: right-aligned, surface bg, no bottom-right radius.
/// AI messages: left-aligned, surfaceLight bg, no bottom-left radius.
class MessageBubble extends StatefulWidget {
  final MessageModel message;

  const MessageBubble({super.key, required this.message});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Slide from bottom 20px, fade in
    final isUser = widget.message.isUser;
    _slideAnimation = Tween<Offset>(
      begin: Offset(isUser ? 0.1 : -0.1, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;

    // System messages: centered, muted
    if (message.isSystem) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Center(
            child: Text(
              message.content,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    final isUser = message.isUser;
    final screenWidth = MediaQuery.of(context).size.width;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                // AI avatar dot
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 8, bottom: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accentPurple.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: AppColors.accentPurple,
                  ),
                ),
              ],
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      screenWidth * (isUser ? 0.75 : 0.80),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.surface : AppColors.surfaceLight,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isUser ? 12 : 2),
                      bottomRight: Radius.circular(isUser ? 2 : 12),
                    ),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isUser
                              ? AppColors.textPrimary
                              : AppColors.textPrimary.withOpacity(0.95),
                          height: 1.45,
                        ),
                      ),
                      if (message.status == MessageStatus.failed) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 12,
                              color: AppColors.destructive,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Failed to send',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.destructive),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
