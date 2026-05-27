// lib/models/message_model.dart

import 'package:uuid/uuid.dart';

enum MessageStatus { sending, sent, failed }
enum MessageSender { user, ai, system }

class MessageModel {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final MessageStatus status;

  const MessageModel({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  /// Factory for user messages
  factory MessageModel.user(String content) {
    return MessageModel(
      id: const Uuid().v4(),
      content: content,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
  }

  /// Factory for AI responses
  factory MessageModel.ai(String content) {
    return MessageModel(
      id: const Uuid().v4(),
      content: content,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );
  }

  /// Factory for system messages (session end, etc.)
  factory MessageModel.system(String content) {
    return MessageModel(
      id: const Uuid().v4(),
      content: content,
      sender: MessageSender.system,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );
  }

  bool get isUser => sender == MessageSender.user;
  bool get isAi => sender == MessageSender.ai;
  bool get isSystem => sender == MessageSender.system;

  MessageModel copyWith({
    String? content,
    MessageStatus? status,
  }) {
    return MessageModel(
      id: id,
      content: content ?? this.content,
      sender: sender,
      timestamp: timestamp,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'MessageModel(id: $id, sender: $sender, status: $status)';
}
