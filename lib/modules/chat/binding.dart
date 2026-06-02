// lib/modules/chat/binding.dart

import 'package:get/get.dart';
import '../../services/chat_service.dart';
import 'controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatService>(() => ChatService());
    Get.lazyPut<ChatController>(() => ChatController());
  }
}
