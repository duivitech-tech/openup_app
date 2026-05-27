// lib/modules/home/controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
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
      // 1. Show cached values instantly
      final cachedAlias = await _storage.getNickname();
      alias.value = cachedAlias ?? 'friend';
      isPremium.value = await _storage.getIsPremium();
      final cachedMsgs = await _storage.getMessagesLeft();
      messagesLeft.value = cachedMsgs ?? 0;
      debugPrint('[HomeController] Cache — alias=$alias, msgs=$messagesLeft, premium=$isPremium');

      // 2. Fetch fresh profile from API (has auth token)
      debugPrint('[HomeController] Fetching profile from API…');
      final user = await _userRepo.fetchProfile();
      _applyUser(user);

      // 3. Also refresh device state (messages quota)
      debugPrint('[HomeController] Refreshing device quota…');
      final device = await _deviceRepo.initDevice();
      messagesLeft.value = device.messagesLeft;
      isPremium.value = device.isPremium;
      debugPrint('[HomeController] Device — msgs=${device.messagesLeft}, premium=${device.isPremium}');
    } catch (e) {
      debugPrint('[HomeController] _loadData error (using cache): $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyUser(UserModel? user) {
    if (user == null) return;
    alias.value = user.alias.isNotEmpty ? user.alias : alias.value;
    isPremium.value = user.isPremium;
    if (user.messagesLeft != null) messagesLeft.value = user.messagesLeft!;
    debugPrint('[HomeController] Profile applied — alias=${user.alias}, premium=${user.isPremium}');
  }

  void onNavTap(int index) {
    debugPrint('[HomeController] Nav tapped: $index');
    currentNavIndex.value = index;
    if (index == 1) Get.toNamed(AppRoutes.profile);
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
