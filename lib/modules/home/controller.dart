// lib/modules/home/controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../repositories/device_repository.dart';
import '../../repositories/user_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';

class HomeController extends GetxController {
  late final StorageService _storage;
  late final DeviceRepository _deviceRepo;
  late final UserRepository _userRepo;

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
    _userRepo = Get.find<UserRepository>();
    _loadData();
  }

  Future<void> _loadData() async {
    debugPrint('[HomeController] _loadData called');
    isLoading.value = true;
    try {
      // Show cached nickname instantly
      final cachedAlias = await _storage.getNickname();
      alias.value = cachedAlias ?? 'friend';

      // Fetch fresh profile — source of truth for quota + premium
      final user = await _userRepo.fetchProfile();
      if (user != null) {
        alias.value = user.alias.isNotEmpty ? user.alias : alias.value;
        isPremium.value = user.isPremium;
        messagesLeft.value = user.messagesLeft ?? 0;
        debugPrint('[HomeController] Profile applied — alias=${user.alias}, premium=${user.isPremium}, msgs=${user.messagesLeft}');
      }

      // Register device in background (no data read from response)
      _deviceRepo.initDevice().ignore();
    } catch (e) {
      debugPrint('[HomeController] _loadData error (using cache): $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onNavTap(int index) {
    debugPrint('[HomeController] Nav tapped: $index');
    currentNavIndex.value = index;
  }

  @override
  Future<void> refresh() => _loadData();

  void startChat() {
    debugPrint('[HomeController] startChat → navigating to Chat');
    Get.toNamed(AppRoutes.chat);
  }

  void goToPremium() {
    debugPrint('[HomeController] goToPremium → navigating to Premium');
    Get.toNamed(AppRoutes.premium);
  }

  void goToSettings() {
    debugPrint('[HomeController] goToSettings → switching to Profile tab');
    currentNavIndex.value = 1;
  }
}
