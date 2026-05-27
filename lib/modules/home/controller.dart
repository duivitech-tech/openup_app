// lib/modules/home/controller.dart

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
    _storage = Get.find<StorageService>();
    _deviceRepo = Get.find<DeviceRepository>();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      // Load local identity
      final storedAlias = await _storage.getNickname();
      alias.value = storedAlias ?? 'friend';

      // Load premium status and messages
      isPremium.value = await _storage.getIsPremium();
      final cached = await _storage.getMessagesLeft();
      messagesLeft.value = cached ?? 0;

      // Refresh device state from backend
      final device = await _deviceRepo.initDevice();
      messagesLeft.value = device.messagesLeft;
      isPremium.value = device.isPremium;
    } catch (_) {
      // Use cached values on error
    } finally {
      isLoading.value = false;
    }
  }

  void onNavTap(int index) {
    currentNavIndex.value = index;
    if (index == 1) {
      Get.toNamed(AppRoutes.profile);
    }
  }

  void startChat() {
    Get.toNamed(AppRoutes.chat);
  }

  void goToPremium() {
    Get.toNamed(AppRoutes.premium);
  }

  void goToSettings() {
    Get.toNamed(AppRoutes.profile);
  }


}
