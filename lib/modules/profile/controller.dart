// lib/modules/profile/controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../repositories/user_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';
import '../../widgets/app_snackbar.dart';

class ProfileController extends GetxController {
  late final UserRepository _userRepo;
  late final StorageService _storage;

  final user = Rxn<UserModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _userRepo = Get.find<UserRepository>();
    _storage = Get.find<StorageService>();
    _loadUser();
  }

  Future<void> _loadUser() async {
    isLoading.value = true;
    try {
      final loaded = await _userRepo.loadUserFromStorage();
      user.value = loaded;
    } catch (_) {
      // Fallback to basic alias display
      final alias = await _storage.getNickname();
      user.value = UserModel(alias: alias ?? 'unknown');
    } finally {
      isLoading.value = false;
    }
  }

  void goToSubscription() {
    Get.toNamed(AppRoutes.premium);
  }

  void showPrivacyPolicy() {
    Get.snackbar(
      '',
      'No data is collected or shared.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2A2A32),
      colorText: const Color(0xFFF0EEF4),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      titleText: const SizedBox.shrink(),
    );
  }

  void showAbout() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('OpenUp',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFF0EEF4))),
              const SizedBox(height: 8),
              const Text(
                "Version 1.0.0\n\nOpenUp is a private, session-based AI conversation platform.\nNo data is collected, stored, or shared.",
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A8A9A),
                    height: 1.6),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> clearLocalData() async {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF232329),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Clear all data?',
            style: TextStyle(color: Color(0xFFF0EEF4), fontSize: 17)),
        content: const Text(
          'This will remove your alias, PIN, and all local data. You will start fresh.',
          style: TextStyle(color: Color(0xFF8A8A9A), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF8A8A9A))),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _userRepo.clearAllData();
              AppSnackbar.success('All data cleared.');
              await Future.delayed(const Duration(milliseconds: 600));
              Get.offAllNamed(AppRoutes.onboarding);
            },
            child: const Text('Clear',
                style: TextStyle(color: Color(0xFFC0392B))),
          ),
        ],
      ),
    );
  }

  Future<void> removeIdentity() async {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF232329),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Remove identity?',
            style: TextStyle(color: Color(0xFFF0EEF4), fontSize: 17)),
        content: const Text(
          'Your alias and access settings will be removed. This cannot be undone.',
          style: TextStyle(color: Color(0xFF8A8A9A), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF8A8A9A))),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _userRepo.clearAllData();
              Get.offAllNamed(AppRoutes.onboarding);
            },
            child: const Text('Remove',
                style: TextStyle(color: Color(0xFFC0392B))),
          ),
        ],
      ),
    );
  }

  void endSession() {
    Get.offAllNamed(AppRoutes.home);
  }
}
