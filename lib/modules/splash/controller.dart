// lib/modules/splash/controller.dart
// Navigation logic:
// 1. No deviceId → Onboarding
// 2. Has deviceId + auth token → Home (returning user)
// 3. Has deviceId + alias but no token → Login (had local account, needs to re-authenticate)
// 4. Has deviceId but no alias → Identity (new user)

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../repositories/device_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';

class SplashController extends GetxController {
  late final StorageService _storage;
  late final DeviceRepository _deviceRepo;

  final opacity = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[SplashController] onInit');
    _storage = Get.find<StorageService>();
    _deviceRepo = Get.find<DeviceRepository>();
    _startSequence();
  }

  Future<void> _startSequence() async {
    // Fade in logo
    await Future.delayed(const Duration(milliseconds: 100));
    opacity.value = 1.0;

    // Wait for minimum splash duration and routing decision in parallel
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1800)),
      _determineRoute(),
    ]);
  }

  Future<void> _determineRoute() async {
    debugPrint('[SplashController] _determineRoute started');

    // ── Step 1: Check device ID ───────────────────────────────────────────────
    String? deviceId;
    try {
      deviceId = await _storage.getString('device_id');
      debugPrint('[SplashController] deviceId=$deviceId');
    } catch (e) {
      debugPrint('[SplashController] deviceId read error: $e — going Onboarding');
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    if (deviceId == null || deviceId.isEmpty) {
      debugPrint('[SplashController] No deviceId — going Onboarding');
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    // ── Step 2: Check auth token ──────────────────────────────────────────────
    String? token;
    try {
      token = await _storage.getAuthToken();
      debugPrint('[SplashController] token=${token != null ? "${token.substring(0, 8)}…" : "null"}');
    } catch (e) {
      debugPrint('[SplashController] token read error: $e');
    }

    if (token != null && token.isNotEmpty) {
      // Has valid token — returning authenticated user → Home
      debugPrint('[SplashController] Token found — going Home');

      // Kick off device sync in background (non-blocking)
      _deviceRepo.initDevice().ignore();

      Get.offAllNamed(AppRoutes.home);
      return;
    }

    // ── Step 3: No token — check if alias exists (had account, needs login) ──
    String? alias;
    try {
      alias = await _storage.getNickname();
      debugPrint('[SplashController] alias=$alias');
    } catch (e) {
      debugPrint('[SplashController] alias read error: $e');
    }

    if (alias != null && alias.isNotEmpty) {
      // Had an account locally but no token → send to Login
      debugPrint('[SplashController] Alias exists but no token — going Login');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // ── Step 4: No alias — brand new user → Identity (signup) ────────────────
    debugPrint('[SplashController] No alias — going Identity (signup)');
    Get.offAllNamed(AppRoutes.identity);
  }
}
