// lib/modules/chat/controller.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/message_model.dart';
import '../../repositories/device_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';
import '../../widgets/app_snackbar.dart';

class ChatController extends GetxController {
  late final DeviceRepository _deviceRepo;
  late final StorageService _storage;

  final messages = <MessageModel>[].obs;
  final inputController = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();

  final isAiTyping = false.obs;
  final isSendEnabled = true.obs;
  final inputText = ''.obs;

  // Track streaming for current AI message
  StreamSubscription? _streamSubscription;

  @override
  void onInit() {
    super.onInit();
    _deviceRepo = Get.find<DeviceRepository>();
    _storage = Get.find<StorageService>();

    inputController.addListener(() {
      inputText.value = inputController.text;
    });

    // Add initial AI greeting
    _addInitialGreeting();
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    _streamSubscription?.cancel();
    super.onClose();
  }

  void _addInitialGreeting() {
    messages.add(MessageModel.ai(
      "Hey. What's on your mind? You can say anything here.",
    ));
  }

  Future<void> sendMessage() async {
    final text = inputController.text.trim();
    if (text.isEmpty || !isSendEnabled.value) return;

    // Clear input immediately
    inputController.clear();
    inputText.value = '';

    // Add user message
    final userMsg = MessageModel.user(text);
    messages.add(userMsg);
    _scrollToBottom();

    isSendEnabled.value = false;

    try {
      // Check message quota with backend BEFORE sending
      final isPremium = await _storage.getIsPremium();

      if (!isPremium) {
        final deductResult = await _deviceRepo.deductMessage();

        if (!deductResult.allowed) {
          // Update message status to failed
          _updateMessageStatus(userMsg.id, MessageStatus.failed);
          // Navigate to paywall
          Get.toNamed(AppRoutes.premium);
          return;
        }
      }

      // Mark message as sent
      _updateMessageStatus(userMsg.id, MessageStatus.sent);

      // Show typing indicator
      isAiTyping.value = true;
      _scrollToBottom();

      // Simulate AI typing delay
      await Future.delayed(const Duration(milliseconds: 1200));

      if (!isAiTyping.value) return; // Controller was closed

      isAiTyping.value = false;

      // Stream mock AI response
      await _streamMockResponse(text);
    } on PaywallException {
      _updateMessageStatus(userMsg.id, MessageStatus.failed);
      Get.toNamed(AppRoutes.premium);
    } on AppException catch (e) {
      _updateMessageStatus(userMsg.id, MessageStatus.failed);
      AppSnackbar.error(e.message);
    } catch (e) {
      _updateMessageStatus(userMsg.id, MessageStatus.failed);
      AppSnackbar.error('Something went wrong. Try again.');
    } finally {
      isAiTyping.value = false;
      isSendEnabled.value = true;
    }
  }

  Future<void> _streamMockResponse(String userMessage) async {
    // Generate contextual mock responses
    final response = _generateMockResponse(userMessage);

    // Add an AI message with empty content to start
    final aiMsg = MessageModel.ai('');
    messages.add(aiMsg);
    _scrollToBottom();

    // Stream characters one by one
    final buffer = StringBuffer();
    for (int i = 0; i < response.length; i++) {
      if (!isClosed) {
        buffer.write(response[i]);
        // Replace last message with updated content
        final updated = aiMsg.copyWith(content: buffer.toString());
        messages[messages.length - 1] = updated;
        // Scroll as content grows
        if (i % 15 == 0) _scrollToBottom();
        await Future.delayed(const Duration(milliseconds: 18));
      }
    }
    _scrollToBottom();
  }

  String _generateMockResponse(String userMessage) {
    final lower = userMessage.toLowerCase();
    final responses = <String>[
      "That sounds like a lot to carry. Tell me more — what's been weighing on you most?",
      "I hear you. Sometimes just saying it out loud helps. How long have you been feeling this way?",
      "That makes sense. It's okay to not have it all figured out. What does your gut tell you?",
      "It's a lot. Have you been able to talk to anyone about this, or is this the first time you're saying it?",
      "I'm listening. What happened, if you don't mind sharing?",
      "That's real. And it's okay. What do you think is at the core of it?",
      "Sometimes the feelings that are hardest to say are the most important ones. You're doing something by saying it here.",
      "Yeah. Take your time. There's no rush here.",
      "I notice a lot of weight in what you're saying. Is this something that's been building for a while?",
      "That's brave of you to put into words. What would it feel like if things were different?",
    ];

    // Try to pick a vaguely contextual response
    if (lower.contains('sad') || lower.contains('depress') || lower.contains('cry')) {
      return "It's okay to feel that way. Sadness isn't weakness — it's just your system telling you something matters. What's hurting the most right now?";
    }
    if (lower.contains('anxious') || lower.contains('anxiety') || lower.contains('worried') || lower.contains('stress')) {
      return "Anxiety has a way of making everything feel urgent at once. Let's slow down for a second. What's the one thing that feels most out of control right now?";
    }
    if (lower.contains('alone') || lower.contains('lonely')) {
      return "That feeling of being alone in a room full of people is one of the worst. I'm here, and I'm listening. What does that loneliness feel like for you?";
    }
    if (lower.contains('angry') || lower.contains('mad') || lower.contains('frustrated')) {
      return "Anger usually means something's not right. What happened? Tell me the whole thing.";
    }
    if (lower.contains('tired') || lower.contains('exhausted') || lower.contains('burnout')) {
      return "When was the last time you felt genuinely rested? Not just physically, but in your mind too?";
    }
    if (lower.contains('love') || lower.contains('relationship') || lower.contains('breakup')) {
      return "Matters of the heart always deserve space. What's going on with the person you're thinking about?";
    }
    if (lower.contains('work') || lower.contains('job') || lower.contains('career')) {
      return "Work stress is real and often underestimated. What's been the hardest part of it lately?";
    }
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
      return "Hey. Glad you're here. What's on your mind today?";
    }

    // Random fallback
    final random = Random();
    return responses[random.nextInt(responses.length)];
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
                leading: const Icon(Icons.copy_rounded, color: Color(0xFF8A8A9A), size: 20),
                title: const Text('Copy', style: TextStyle(color: Color(0xFFF0EEF4))),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  Get.back();
                  AppSnackbar.info('Copied to clipboard');
                },
              ),
              if (message.isUser)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFC0392B), size: 20),
                  title: const Text('Delete', style: TextStyle(color: Color(0xFFC0392B))),
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
    messages.add(MessageModel.system('Session ended. Nothing was saved.'));
    _scrollToBottom();
    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
    });
  }
}
