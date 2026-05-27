// lib/modules/chat/view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/message_model.dart';
import '../../themes/app_theme.dart';
import '../../widgets/chat_input_bar.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/session_tag.dart';
import '../../widgets/typing_indicator.dart';
import 'controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: Obx(() {
              final msgs = controller.messages;
              final isTyping = controller.isAiTyping.value;

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: msgs.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isTyping && index == msgs.length) {
                    return const TypingIndicator();
                  }

                  final message = msgs[index];
                  return GestureDetector(
                    onLongPress: () =>
                        controller.onLongPressMessage(message),
                    child: Column(
                      children: [
                        MessageBubble(message: message),
                        // Show retry button on failed messages
                        if (message.status == MessageStatus.failed &&
                            message.isUser)
                          _RetryButton(
                            onRetry: () =>
                                controller.retryMessage(message),
                          ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          // Input bar pinned to bottom
          Obx(() => ChatInputBar(
                controller: controller.inputController,
                focusNode: controller.focusNode,
                onSend: controller.sendMessage,
                isEnabled: controller.isSendEnabled.value,
              )),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgPrimary,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          size: 18,
          color: AppColors.textSecondary,
        ),
        onPressed: () => Get.back(),
      ),
      title: Column(
        children: [
          Text(
            'AI listener',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 2),
          const SessionTag(),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
          onPressed: () => _showChatOptions(context),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          height: 0.5,
          color: AppColors.border,
        ),
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.stop_circle_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                title: Text('End session', style: AppTextStyles.bodyMedium),
                subtitle: Text(
                  'Nothing will be saved.',
                  style: AppTextStyles.bodySmall,
                ),
                onTap: () {
                  Get.back();
                  controller.endSession();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final VoidCallback onRetry;

  const _RetryButton({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onRetry,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.refresh_rounded,
                  size: 13,
                  color: AppColors.accentPurple,
                ),
                const SizedBox(width: 4),
                Text(
                  'Retry',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
