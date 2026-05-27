// lib/modules/splash/controller.dart

import 'package:get/get.dart';
import '../../core/errors/app_exceptions.dart';
import '../../repositories/device_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';

class SplashController extends GetxController {
  late final StorageService _storage;
  late final DeviceRepository _deviceRepo;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<StorageService>();
    _deviceRepo = Get.find<DeviceRepository>();
    _initialize();
  }

  Future<void> _initialize() async {
    // Wait for the minimum splash display time
    await Future.delayed(
      const Duration(milliseconds: 1800),
    );

    try {
      final deviceId = await _storage.getDeviceId();

      if (deviceId == null || deviceId.isEmpty) {
        // First launch — show onboarding
        Get.offAllNamed(AppRoutes.onboarding);
        return;
      }

      // Device exists — initialize session with backend
      await _deviceRepo.initDevice();

      // Check if alias is set up
      final alias = await _storage.getNickname();
      if (alias == null || alias.isEmpty) {
        // Device exists but identity not set up
        Get.offAllNamed(AppRoutes.identity);
        return;
      }

      // All good — go to home
      Get.offAllNamed(AppRoutes.home);
    } on AppException catch (_) {
      // On error, try to navigate based on cached data
      final alias = await _storage.getNickname();
      if (alias != null && alias.isNotEmpty) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.onboarding);
      }
    } catch (_) {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
