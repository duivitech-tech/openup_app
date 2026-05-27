// lib/modules/identity/controller.dart

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

  // Preview ID shown below alias field
  String get previewId {
    final a = alias.value.isNotEmpty ? alias.value : 'alias';
    return '$a-${pin.value.isNotEmpty ? pin.value : "XXXX"}';
  }

  @override
  void onInit() {
    super.onInit();
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

  void togglePinVisibility() => pinVisible.toggle();

  String? validateAlias(String? value) => Validators.validateAlias(value);
  String? validatePin(String? value) => Validators.validatePin(value);

  Future<void> enterOpenUp() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      // Ensure device ID is created
      await _deviceRepo.getDeviceId();

      // Save alias + PIN locally — no API call for free tier
      await _userRepo.saveLocalIdentity(aliasController.text.trim(), pinController.text);

      // Initialize device session in background
      _deviceRepo.initDevice().ignore();

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      AppSnackbar.error('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
