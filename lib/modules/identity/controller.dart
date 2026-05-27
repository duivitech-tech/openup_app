// lib/modules/identity/controller.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/validators.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/device_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_snackbar.dart';

class IdentityController extends GetxController {
  late final UserRepository _userRepo;
  late final DeviceRepository _deviceRepo;

  final formKey = GlobalKey<FormState>();
  final aliasController = TextEditingController();
  final pinController = TextEditingController();

  final alias = ''.obs;
  final pin = ''.obs;
  final pinVisible = false.obs;
  final isLoading = false.obs;

  String get previewId {
    final a = alias.value.isNotEmpty ? alias.value : 'alias';
    return '$a-${pin.value.isNotEmpty ? pin.value : "XXXX"}';
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint('[IdentityController] onInit');
    _userRepo = Get.find<UserRepository>();
    _deviceRepo = Get.find<DeviceRepository>();

    aliasController.addListener(() => alias.value = aliasController.text);
    pinController.addListener(() => pin.value = pinController.text);
  }

  @override
  void onClose() {
    aliasController.dispose();
    pinController.dispose();
    super.onClose();
  }

  void togglePinVisibility() {
    pinVisible.toggle();
    debugPrint('[IdentityController] pinVisible = ${pinVisible.value}');
  }

  String? validateAlias(String? value) => Validators.validateAlias(value);
  String? validatePin(String? value) => Validators.validatePin(value);

  Future<void> enterOpenUp() async {
    debugPrint('[IdentityController] enterOpenUp called');
    if (!formKey.currentState!.validate()) {
      debugPrint('[IdentityController] Form validation failed');
      return;
    }

    isLoading.value = true;
    try {
      // Ensure device ID exists
      final deviceId = await _deviceRepo.getDeviceId();
      debugPrint('[IdentityController] deviceId=$deviceId — saving identity');

      // Save alias + PIN locally
      await _userRepo.saveLocalIdentity(
        aliasController.text.trim(),
        pinController.text,
      );

      debugPrint('[IdentityController] Identity saved. Navigating to Home.');

      // Kick off device init in background (non-blocking)
      _deviceRepo.initDevice().ignore();

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      debugPrint('[IdentityController] enterOpenUp error: $e');
      AppSnackbar.error('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
