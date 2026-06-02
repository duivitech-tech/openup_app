// lib/services/chat_service.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/constants/api_constants.dart';

class ChatService extends GetxService {
  io.Socket? _socket;

  // Callbacks set by ChatController
  void Function(String sessionId, String greeting)? onSessionStarted;
  void Function(String chunk)? onChunk;
  void Function(String fullMessage)? onResponse;
  void Function(String message)? onSessionEnded;
  void Function(String error)? onError;
  void Function()? onDisconnected;
  void Function()? onConnected;

  bool get isConnected => _socket?.connected ?? false;

  /// Connects to the Socket.IO server and starts a session.
  void connect({required String userName}) {
    debugPrint('[ChatService] Connecting to ${ApiConstants.chatBaseUrl}');

    _socket = io.io(
      ApiConstants.chatBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[ChatService] Connected — starting session for $userName');
      onConnected?.call();
      _socket!.emit('start_session', {
        'user_name': userName,
        'mood': 'lonely',
      });
    });

    _socket!.on('session_started', (data) {
      debugPrint('[ChatService] session_started: $data');
      final sessionId = data['session_id'] as String? ?? '';
      final message = data['message'] as String? ?? '';
      onSessionStarted?.call(sessionId, message);
    });

    _socket!.on('chat_chunk', (data) {
      final chunk = data['chunk'] as String? ?? '';
      onChunk?.call(chunk);
    });

    _socket!.on('chat_response', (data) {
      debugPrint('[ChatService] chat_response received');
      final message = data['message'] as String? ?? '';
      onResponse?.call(message);
    });

    _socket!.on('session_ended', (data) {
      debugPrint('[ChatService] session_ended: $data');
      final message = data['message'] as String? ?? 'Session ended.';
      onSessionEnded?.call(message);
    });

    _socket!.on('error', (data) {
      debugPrint('[ChatService] error: $data');
      final message = data['message'] as String? ?? 'Something went wrong.';
      onError?.call(message);
    });

    _socket!.onDisconnect((_) {
      debugPrint('[ChatService] Disconnected');
      onDisconnected?.call();
    });

    _socket!.connect();
  }

  /// Sends a user message.
  void sendMessage(String message) {
    if (!isConnected) {
      debugPrint('[ChatService] sendMessage called but not connected');
      return;
    }
    debugPrint('[ChatService] emit chat: $message');
    _socket!.emit('chat', {
      'message': message,
      'auto_detect_mood': true,
    });
  }

  /// Ends the session server-side.
  void endSession() {
    if (!isConnected) return;
    debugPrint('[ChatService] emit end_session');
    _socket!.emit('end_session', {});
  }

  /// Disconnects and cleans up.
  void disconnect() {
    debugPrint('[ChatService] disconnect called');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
