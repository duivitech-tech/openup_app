// lib/modules/login/controller.dart
// Login screen — calls /api/auth/login, stores token, navigates to Home

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/utils/validators.dart';
import '../../repositories/device_repository.dart';
import '../../repositories/user_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_toast.dart';

class LoginController extends GetxController {
  late final UserRepository _userRepo;
  late final DeviceRepository _deviceRepo;

  final formKey = GlobalKey<FormState>();
  final aliasController = TextEditingController();
  final pinController = TextEditingController();

  final alias = ''.obs;
  final pin = ''.obs;
  final pinVisible = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[LoginController] onInit');
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
  String? validateAlias(String? v) => Validators.validateAlias(v);
  String? validatePin(String? v) => Validators.validatePin(v);

  void goToSignup() => Get.offAllNamed(AppRoutes.identity);

  Future<void> login() async {
    debugPrint('[LoginController] login called');
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final deviceId = await _deviceRepo.getDeviceId();
      debugPrint('[LoginController] deviceId=$deviceId — calling login API');

      await _userRepo.login(
        deviceId: deviceId,
        alias: aliasController.text.trim(),
        pin: pinController.text,
      );

      debugPrint('[LoginController] Login success — navigating to Home');
      _deviceRepo.initDevice().ignore();
      Get.offAllNamed(AppRoutes.home);
    } on InvalidCredentialsException catch (e) {
      debugPrint('[LoginController] InvalidCredentials: ${e.message}');
      AppToast.error(e.message);
    } on UserNotFoundException catch (e) {
      debugPrint('[LoginController] UserNotFound: ${e.message}');
      AppToast.error(e.message);
    } on AppException catch (e) {
      debugPrint('[LoginController] AppException: ${e.message}');
      AppToast.error(e.message);
    } catch (e) {
      debugPrint('[LoginController] Unexpected error: $e');
      AppToast.error('Login failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
