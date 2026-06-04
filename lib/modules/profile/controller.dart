// lib/modules/profile/controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../repositories/user_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_toast.dart';

class ProfileController extends GetxController {
  late final UserRepository _userRepo;

  final user = Rxn<UserModel>();
  final isLoading = false.obs;
  final isDeleting = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[ProfileController] onInit');
    _userRepo = Get.find<UserRepository>();
    _loadUser();
  }

  Future<void> _loadUser() async {
    debugPrint('[ProfileController] _loadUser called');
    isLoading.value = true;
    try {
      final loaded = await _userRepo.fetchProfile();
      user.value = loaded;
      debugPrint('[ProfileController] Loaded user: ${user.value}');
    } catch (e) {
      debugPrint('[ProfileController] _loadUser error: $e');
      AppToast.error('Failed to load profile.');
      user.value = UserModel(alias: 'unknown');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => _loadUser();

  void goToSubscription() => Get.toNamed(AppRoutes.premium);

  void showPrivacyPolicy() {
    Get.toNamed(AppRoutes.privacyPolicy);
  }

  void showAbout() {
    Get.toNamed(AppRoutes.aboutUs);
  }

  /// Clears all data and logs out — hits logout API then goes to onboarding.
  Future<void> clearLocalData() async {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF232329),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Clear all data?',
            style: TextStyle(color: Color(0xFFF0EEF4), fontSize: 17)),
        content: const Text(
          'This will log you out and remove all local data. You will start fresh.',
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
              await _performLogout();
            },
            child: const Text('Clear',
                style: TextStyle(color: Color(0xFFC0392B))),
          ),
        ],
      ),
    );
  }

  /// Delete account — calls DELETE /api/user/delete-account, wipes storage, navigates to login.
  Future<void> removeIdentity() async {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF232329),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete account?',
            style: TextStyle(color: Color(0xFFF0EEF4), fontSize: 17)),
        content: const Text(
          'This will permanently delete your account and all associated data. This cannot be undone.',
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
              await _performDeleteAccount();
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFC0392B))),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteAccount() async {
    debugPrint('[ProfileController] _performDeleteAccount called');
    isDeleting.value = true;
    try {
      await _userRepo.deleteAccount();
      debugPrint('[ProfileController] Account deleted — navigating to login');
      AppSnackbar.success('Account deleted.');
      await Future.delayed(const Duration(milliseconds: 400));
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      debugPrint('[ProfileController] deleteAccount error: $e');
      AppToast.error('Failed to delete account. Please try again.');
    } finally {
      isDeleting.value = false;
    }
  }

  /// Calls logout API, clears storage, navigates to login.
  Future<void> _performLogout() async {
    debugPrint('[ProfileController] _performLogout called');
    try {
      await _userRepo.logout();
      debugPrint('[ProfileController] Logout complete — navigating to login');
      AppSnackbar.success('Logged out successfully.');
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      debugPrint('[ProfileController] Logout error: $e');
    } finally {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF232329),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Log out?',
            style: TextStyle(color: Color(0xFFF0EEF4), fontSize: 17)),
        content: const Text(
          'You will be returned to the login screen.',
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
              await _performLogout();
            },
            child: const Text('Log out',
                style: TextStyle(color: Color(0xFFC0392B))),
          ),
        ],
      ),
    );
  }
}
