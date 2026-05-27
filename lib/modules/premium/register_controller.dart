// lib/modules/premium/register_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/utils/validators.dart';
import '../../repositories/device_repository.dart';
import '../../repositories/user_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';
import '../../widgets/app_snackbar.dart';

class PremiumRegisterController extends GetxController {
  late final DeviceRepository _deviceRepo;
  late final UserRepository _userRepo;
  late final StorageService _storage;

  final formKey = GlobalKey<FormState>();
  final nicknameController = TextEditingController();
  final pinController = TextEditingController();

  final isLoading = false.obs;
  final pinVisible = false.obs;
  final showWebView = false.obs;
  final paymentUrl = ''.obs;
  final planType = ''.obs;
  final paymentCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();
    _deviceRepo = Get.find<DeviceRepository>();
    _userRepo = Get.find<UserRepository>();
    _storage = Get.find<StorageService>();

    // Pre-fill nickname from alias
    _loadAlias();

    // Get args from navigation
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      paymentUrl.value = args['paymentUrl'] as String? ?? '';
      planType.value = args['planType'] as String? ?? 'monthly';
      // Automatically show WebView for payment
      if (paymentUrl.value.isNotEmpty) {
        showWebView.value = true;
      }
    }
  }

  Future<void> _loadAlias() async {
    final alias = await _storage.getNickname();
    if (alias != null && alias.isNotEmpty) {
      nicknameController.text = alias;
    }
  }

  @override
  void onClose() {
    nicknameController.dispose();
    pinController.dispose();
    super.onClose();
  }

  void togglePinVisibility() => pinVisible.toggle();

  void onPaymentComplete() {
    showWebView.value = false;
    paymentCompleted.value = true;
  }

  void onPaymentFailed() {
    showWebView.value = false;
    AppSnackbar.error('Payment was not completed. Please try again.');
  }

  String? validateNickname(String? value) => Validators.validateAlias(value);
  String? validatePin(String? value) => Validators.validatePin(value);

  Future<void> activateAccess() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final deviceId = await _deviceRepo.getDeviceId();

      await _userRepo.registerPremium(
        deviceId: deviceId,
        name: nicknameController.text.trim(),
        pin: pinController.text,
        planType: planType.value,
      );

      AppSnackbar.success('Plus access activated!');

      // Small delay to show the success message
      await Future.delayed(const Duration(milliseconds: 800));

      Get.offAllNamed(AppRoutes.home);
    } on AlreadyRegisteredException {
      AppSnackbar.error('This device already has an account.');
      await Future.delayed(const Duration(milliseconds: 1000));
      Get.offAllNamed(AppRoutes.home);
    } on NoPaymentException {
      AppSnackbar.error('Payment not verified yet. Please wait a moment and try again.');
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Activation failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
