// lib/widgets/message_bubble.dart
// Pure StatelessWidget — animation via TweenAnimationBuilder (no AnimationController needed)

import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../themes/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // System messages: centered, muted
    if (message.isSystem) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (_, value, child) => Opacity(opacity: value, child: child),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Center(
            child: Text(
              message.content,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    final isUser = message.isUser;
    final screenWidth = MediaQuery.of(context).size.width;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(
            isUser ? (1.0 - value) * 16 : -(1.0 - value) * 16,
            (1.0 - value) * 12,
          ),
          child: child,
        ),
      ),
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
                  color: AppColors.accentPurple.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentPurple.withValues(alpha: 0.4),
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
                maxWidth: screenWidth * (isUser ? 0.75 : 0.80),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.surface : AppColors.surfaceLight,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: Radius.circular(isUser ? 12 : 2),
                    bottomRight: Radius.circular(isUser ? 2 : 12),
                  ),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
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
                            : AppColors.textPrimary.withValues(alpha: 0.95),
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
    );
  }
}
