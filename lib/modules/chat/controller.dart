// lib/modules/chat/controller.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/message_model.dart';
import '../../repositories/device_repository.dart';
// TODO(premium): Restore when payment gateway is ready.
// import '../../routes/app_routes.dart';
import '../../services/chat_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/app_snackbar.dart';

class ChatController extends GetxController {
  late final DeviceRepository _deviceRepo;
  late final ChatService _chatService;
  late final StorageService _storage;

  final messages = <MessageModel>[].obs;
  final inputController = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();

  final isAiTyping = false.obs;
  final isSendEnabled = false.obs; // disabled until session starts
  final inputText = ''.obs;
  final isConnected = false.obs;

  // Tracks the AI message being streamed
  String? _streamingMessageId;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[ChatController] onInit');
    _deviceRepo = Get.find<DeviceRepository>();
    _chatService = Get.find<ChatService>();
    _storage = Get.find<StorageService>();

    inputController.addListener(() {
      inputText.value = inputController.text;
    });

    _connectChat();
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    _chatService.disconnect();
    super.onClose();
  }

  void _connectChat() async {
    final alias = await _storage.getNickname() ?? 'User';

    _chatService.onConnected = () {
      debugPrint('[ChatController] Socket connected');
      isConnected.value = true;
    };

    _chatService.onSessionStarted = (sessionId, greeting) {
      debugPrint('[ChatController] Session started: $sessionId');
      if (greeting.isNotEmpty) {
        messages.add(MessageModel.ai(greeting));
        _scrollToBottom();
      }
      isSendEnabled.value = true;
    };

    _chatService.onChunk = (chunk) {
      if (_streamingMessageId == null) {
        // First chunk — create a new AI message
        final aiMsg = MessageModel.ai(chunk);
        _streamingMessageId = aiMsg.id;
        messages.add(aiMsg);
      } else {
        // Append chunk to existing streaming message
        final index = messages.indexWhere((m) => m.id == _streamingMessageId);
        if (index != -1) {
          messages[index] = messages[index].copyWith(
            content: messages[index].content + chunk,
          );
        }
      }
      _scrollToBottom();
    };

    _chatService.onResponse = (fullMessage) {
      debugPrint('[ChatController] Full response received');
      // If chunks were received, the message is already built — just finalize
      // If no chunks came (fallback), add the full message now
      if (_streamingMessageId == null) {
        messages.add(MessageModel.ai(fullMessage));
        _scrollToBottom();
      }
      _streamingMessageId = null;
      isAiTyping.value = false;
      isSendEnabled.value = true;
    };

    _chatService.onSessionEnded = (message) {
      messages.add(MessageModel.system(message));
      _scrollToBottom();
      isSendEnabled.value = false;
    };

    _chatService.onError = (error) {
      debugPrint('[ChatController] Socket error: $error');
      isAiTyping.value = false;
      isSendEnabled.value = true;
      _streamingMessageId = null;
      AppSnackbar.error(error);
    };

    _chatService.onDisconnected = () {
      debugPrint('[ChatController] Socket disconnected');
      isConnected.value = false;
      isSendEnabled.value = false;
    };

    _chatService.connect(userName: alias);
  }

  Future<void> sendMessage() async {
    final text = inputController.text.trim();
    if (text.isEmpty || !isSendEnabled.value) return;

    debugPrint('[ChatController] sendMessage: "$text"');

    inputController.clear();
    inputText.value = '';

    final userMsg = MessageModel.user(text);
    messages.add(userMsg);
    _scrollToBottom();

    isSendEnabled.value = false;

    try {
      // Deduct message credit via JWT
      final deductResult = await _deviceRepo.deductMessage();
      debugPrint('[ChatController] deductMessage: allowed=${deductResult.allowed}');

      if (!deductResult.allowed) {
        _updateMessageStatus(userMsg.id, MessageStatus.failed);
        isSendEnabled.value = true;
        // TODO(premium): Navigate to premium screen when payment gateway is ready.
        // Get.toNamed(AppRoutes.premium);
        _showDailyLimitDialog(messagesLeft: deductResult.messagesLeft);
        return;
      }

      _updateMessageStatus(userMsg.id, MessageStatus.sent);
      isAiTyping.value = true;
      _scrollToBottom();

      // Send to chatbot via socket
      _chatService.sendMessage(text);

    } on PaywallException {
      debugPrint('[ChatController] PaywallException');
      _updateMessageStatus(userMsg.id, MessageStatus.failed);
      isAiTyping.value = false;
      isSendEnabled.value = true;
      // TODO(premium): Navigate to premium screen when payment gateway is ready.
      // Get.toNamed(AppRoutes.premium);
      _showDailyLimitDialog(messagesLeft: null);
    } on AppException catch (e) {
      debugPrint('[ChatController] AppException: ${e.message}');
      _updateMessageStatus(userMsg.id, MessageStatus.failed);
      isAiTyping.value = false;
      isSendEnabled.value = true;
      AppSnackbar.error(e.message);
    } catch (e) {
      debugPrint('[ChatController] Unexpected error: $e');
      _updateMessageStatus(userMsg.id, MessageStatus.failed);
      isAiTyping.value = false;
      isSendEnabled.value = true;
      AppSnackbar.error('Something went wrong. Try again.');
    }
  }

  void _updateMessageStatus(String id, MessageStatus status) {
    final index = messages.indexWhere((m) => m.id == id);
    if (index != -1) {
      messages[index] = messages[index].copyWith(status: status);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void onLongPressMessage(MessageModel message) {
    if (message.isSystem) return;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1E),
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
                  color: const Color(0xFF2A2A35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded,
                    color: Color(0xFF8A8A9A), size: 20),
                title: const Text('Copy',
                    style: TextStyle(color: Color(0xFFF0EEF4))),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  Get.back();
                  AppSnackbar.info('Copied to clipboard');
                },
              ),
              if (message.isUser)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFC0392B), size: 20),
                  title: const Text('Delete',
                      style: TextStyle(color: Color(0xFFC0392B))),
                  onTap: () {
                    messages.removeWhere((m) => m.id == message.id);
                    Get.back();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void retryMessage(MessageModel failedMessage) {
    final index = messages.indexWhere((m) => m.id == failedMessage.id);
    if (index != -1) {
      messages.removeAt(index);
      inputController.text = failedMessage.content;
    }
  }

  void endSession() {
    _chatService.endSession();
    messages.add(MessageModel.system('Session ended. Nothing was saved.'));
    _scrollToBottom();
    isSendEnabled.value = false;
    Future.delayed(const Duration(seconds: 2), () => Get.back());
  }

  // TODO(premium): Replace this with premium screen navigation when payment gateway is ready.
  /// Shows a friendly bottom sheet when the daily message limit is reached.
  /// [messagesLeft] comes from the backend deduct response — null means the
  /// value wasn't available (e.g. a 403 thrown before the response was parsed).
  void _showDailyLimitDialog({int? messagesLeft}) {
    // Build a human-readable subtitle from whatever the backend gave us.
    final String subtitle;
    if (messagesLeft != null && messagesLeft <= 0) {
      subtitle =
          "You've reached your daily message limit.\nYour limit refills automatically tomorrow — come back then.";
    } else if (messagesLeft != null && messagesLeft > 0) {
      // Shouldn't normally happen (allowed would be true), but handle gracefully.
      subtitle =
          "You have $messagesLeft message${messagesLeft == 1 ? '' : 's'} left today.\nYour limit refills automatically tomorrow.";
    } else {
      // No count available — generic copy.
      subtitle =
          "You've reached your daily message limit.\nYour limit refills automatically tomorrow — come back then.";
    }

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag handle
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF232329),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.hourglass_bottom_rounded,
                    color: Color(0xFF8B7CF6),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "You're all caught up for today",
                  style: TextStyle(
                    color: Color(0xFFF0EEF4),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF8A8A9A),
                    fontSize: 13,
                    height: 1.5,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B7CF6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }
}
