// lib/modules/home/controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../repositories/device_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';

class HomeController extends GetxController {
  late final StorageService _storage;
  late final DeviceRepository _deviceRepo;

  final alias = ''.obs;
  final messagesLeft = 0.obs;
  final isPremium = false.obs;
  final isLoading = false.obs;
  final currentNavIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[HomeController] onInit');
    _storage = Get.find<StorageService>();
    _deviceRepo = Get.find<DeviceRepository>();
    _loadData();
  }

  Future<void> _loadData() async {
    debugPrint('[HomeController] _loadData called');
    isLoading.value = true;
    try {
      // Load local identity
      final storedAlias = await _storage.getNickname();
      alias.value = storedAlias ?? 'friend';
      debugPrint('[HomeController] alias=$alias');

      // Load cached premium status and messages
      isPremium.value = await _storage.getIsPremium();
      final cached = await _storage.getMessagesLeft();
      messagesLeft.value = cached ?? 0;
      debugPrint('[HomeController] cache → messagesLeft=$messagesLeft, isPremium=$isPremium');

      // Refresh from backend
      debugPrint('[HomeController] Refreshing device state from backend…');
      final device = await _deviceRepo.initDevice();
      messagesLeft.value = device.messagesLeft;
      isPremium.value = device.isPremium;
      debugPrint('[HomeController] Backend → messagesLeft=${device.messagesLeft}, isPremium=${device.isPremium}');
    } catch (e) {
      debugPrint('[HomeController] _loadData error (using cache): $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onNavTap(int index) {
    debugPrint('[HomeController] Nav tapped: $index');
    currentNavIndex.value = index;
    if (index == 1) {
      Get.toNamed(AppRoutes.profile);
    }
  }

  void startChat() {
    debugPrint('[HomeController] startChat → navigating to Chat');
    Get.toNamed(AppRoutes.chat);
  }

  void goToPremium() {
    debugPrint('[HomeController] goToPremium → navigating to Premium');
    Get.toNamed(AppRoutes.premium);
  }

  void goToSettings() {
    debugPrint('[HomeController] goToSettings → navigating to Profile');
    Get.toNamed(AppRoutes.profile);
  }
}
