// lib/modules/splash/controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../repositories/device_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';

class SplashController extends GetxController {
  late final StorageService _storage;
  late final DeviceRepository _deviceRepo;

  // Drives the fade-in animation in the view (0.0 → 1.0)
  final opacity = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[Splash] onInit — finding services');
    _storage = Get.find<StorageService>();
    _deviceRepo = Get.find<DeviceRepository>();
    _initialize();
  }

  Future<void> _initialize() async {
    debugPrint('[Splash] Starting initialization…');

    // Trigger fade-in
    await Future.delayed(const Duration(milliseconds: 100));
    opacity.value = 1.0;

    // Minimum display time
    await Future.delayed(const Duration(milliseconds: 1600));

    debugPrint('[Splash] Minimum display time done. Reading storage…');

    try {
      // ── Step 1: Check if device ID exists ─────────────────────────────────
      String? deviceId;
      try {
        deviceId = await _storage.getDeviceId();
        debugPrint('[Splash] deviceId from storage: $deviceId');
      } catch (e) {
        debugPrint('[Splash] ERROR reading deviceId: $e');
        deviceId = null;
      }

      if (deviceId == null || deviceId.isEmpty) {
        debugPrint('[Splash] No deviceId → navigating to Onboarding');
        Get.offAllNamed(AppRoutes.onboarding);
        return;
      }

      // ── Step 2: Try to sync with backend (non-blocking on failure) ─────────
      debugPrint('[Splash] deviceId=$deviceId — calling initDevice…');
      try {
        final device = await _deviceRepo.initDevice();
        debugPrint(
            '[Splash] initDevice success → messagesLeft=${device.messagesLeft}, isPremium=${device.isPremium}');
      } catch (e) {
        debugPrint('[Splash] initDevice failed (will use cache): $e');
        // Not fatal — continue with cached data
      }

      // ── Step 3: Check identity ─────────────────────────────────────────────
      String? alias;
      try {
        alias = await _storage.getNickname();
        debugPrint('[Splash] alias from storage: $alias');
      } catch (e) {
        debugPrint('[Splash] ERROR reading alias: $e');
        alias = null;
      }

      if (alias == null || alias.isEmpty) {
        debugPrint('[Splash] No alias → navigating to Identity setup');
        Get.offAllNamed(AppRoutes.identity);
        return;
      }

      // ── Step 4: All good — go home ─────────────────────────────────────────
      debugPrint('[Splash] All checks passed → navigating to Home');
      Get.offAllNamed(AppRoutes.home);
    } catch (e, stack) {
      debugPrint('[Splash] UNEXPECTED ERROR: $e\n$stack');
      // Safe fallback — always navigate somewhere
      _safeNavigate();
    }
  }

  Future<void> _safeNavigate() async {
    debugPrint('[Splash] Safe fallback navigation…');
    try {
      final alias = await _storage.getNickname();
      if (alias != null && alias.isNotEmpty) {
        debugPrint('[Splash] fallback → Home (alias exists)');
        Get.offAllNamed(AppRoutes.home);
      } else {
        debugPrint('[Splash] fallback → Onboarding');
        Get.offAllNamed(AppRoutes.onboarding);
      }
    } catch (_) {
      debugPrint('[Splash] fallback → Onboarding (storage error)');
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
