// lib/widgets/chat_input_bar.dart

import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// Pinned bottom input bar: text field + send button + disabled mic icon.
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback? onSend;
  final bool isEnabled;
  final String hint;

  const ChatInputBar({
    super.key,
    required this.controller,
    this.focusNode,
    this.onSend,
    this.isEnabled = true,
    this.hint = 'say something...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 12,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 48,
                maxHeight: 120,
              ),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: isEnabled,
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                scrollPhysics: const BouncingScrollPhysics(),
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  isDense: true,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Mic (disabled in MVP)
          // Container(
          //   width: 40,
          //   height: 40,
          //   decoration: BoxDecoration(
          //     color: AppColors.surface,
          //     shape: BoxShape.circle,
          //     border: Border.all(color: AppColors.border, width: 0.5),
          //   ),
          //   child: Icon(
          //     Icons.mic_none_rounded,
          //     size: 18,
          //     color: AppColors.textSecondary.withValues(alpha: 0.4),
          //   ),
          // ),

          const SizedBox(width: 6),

          // Send button
          GestureDetector(
            onTap: isEnabled ? onSend : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isEnabled
                    ? const LinearGradient(
                        colors: [Color(0xFF8B7CF6), Color(0xFF6B5CE7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isEnabled ? null : AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: AppColors.accentPurple.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                size: 18,
                color: isEnabled
                    ? AppColors.onAccent
                    : AppColors.textSecondary.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
