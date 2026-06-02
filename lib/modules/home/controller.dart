// lib/modules/home/controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../repositories/app_update_repository.dart';
import '../../repositories/device_repository.dart';
import '../../repositories/user_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';
import '../../widgets/app_update_dialog.dart';

class HomeController extends GetxController {
  late final StorageService _storage;
  late final DeviceRepository _deviceRepo;
  late final UserRepository _userRepo;
  late final AppUpdateRepository _updateRepo;

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
    _updateRepo = Get.find<AppUpdateRepository>();
    _loadData();
    _checkForAppUpdate(); // always run on every init
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

  /// Checks for an available app update every time the home screen is shown.
  /// Shows the appropriate dialog (force or optional) without blocking the UI.
  Future<void> _checkForAppUpdate() async {
    debugPrint('[HomeController] _checkForAppUpdate called');
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version;                           // e.g. "1.0.0"
      final buildNumber = int.tryParse(info.buildNumber) ?? 1; // e.g. 1
      debugPrint('[HomeController] App version=$version, versionCode=$buildNumber');

      final update = await _updateRepo.checkForUpdate(
        platform: 'android',
        version: version,
        versionCode: buildNumber,
      );

      if (update == null) {
        debugPrint('[HomeController] Update check returned null — skipping');
        return;
      }

      debugPrint('[HomeController] Update check result: $update');

      if (!update.updateAvailable) {
        debugPrint('[HomeController] No update available — nothing to show');
        return;
      }

      // Small delay so the home screen renders first before showing the dialog
      await Future.delayed(const Duration(milliseconds: 600));

      // Show the dialog
      await showAppUpdateDialog(update);
    } catch (e) {
      // Never crash the home screen because of an update check failure
      debugPrint('[HomeController] _checkForAppUpdate error (silent): $e');
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

  // TODO(premium): Re-enable when payment gateway is ready.
  void goToPremium() {
    debugPrint('[HomeController] goToPremium — premium disabled until payment gateway is ready');
    // Get.toNamed(AppRoutes.premium);
  }

  void goToSettings() {
    debugPrint('[HomeController] goToSettings → switching to Profile tab');
    currentNavIndex.value = 1;
  }
}
