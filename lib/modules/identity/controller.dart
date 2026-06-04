// lib/modules/identity/controller.dart
// Signup screen — calls /api/auth/signup, stores token, navigates to Home

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/utils/validators.dart';
import '../../repositories/device_repository.dart';
import '../../repositories/user_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_toast.dart';

enum AliasStatus { idle, checking, available, taken }

class IdentityController extends GetxController {
  late final UserRepository _userRepo;
  late final DeviceRepository _deviceRepo;

  final formKey = GlobalKey<FormState>();
  final aliasController = TextEditingController();
  final pinController = TextEditingController();
  final aliasFocusNode = FocusNode();

  final alias = ''.obs;
  final pin = ''.obs;
  final pinVisible = false.obs;
  final isLoading = false.obs;
  final aliasStatus = AliasStatus.idle.obs;

  String get previewId {
    final a = alias.value.isNotEmpty ? alias.value : 'alias';
    return '$a · ${pin.value.isNotEmpty ? '••••' : 'XXXX'}';
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint('[IdentityController] onInit');
    _userRepo = Get.find<UserRepository>();
    _deviceRepo = Get.find<DeviceRepository>();
    aliasController.addListener(() => alias.value = aliasController.text);
    pinController.addListener(() => pin.value = pinController.text);
    aliasFocusNode.addListener(_onAliasFocusChange);
  }

  @override
  void onClose() {
    aliasController.dispose();
    pinController.dispose();
    aliasFocusNode.removeListener(_onAliasFocusChange);
    aliasFocusNode.dispose();
    super.onClose();
  }

  void _onAliasFocusChange() {
    if (!aliasFocusNode.hasFocus) {
      _checkAlias();
    }
  }

  Future<void> _checkAlias() async {
    final value = aliasController.text.trim();
    if (value.isEmpty || Validators.validateAlias(value) != null) {
      aliasStatus.value = AliasStatus.idle;
      return;
    }
    debugPrint('[IdentityController] checking alias availability: $value');
    aliasStatus.value = AliasStatus.checking;
    try {
      final available = await _userRepo.isNameAvailable(value);
      aliasStatus.value = available ? AliasStatus.available : AliasStatus.taken;
      debugPrint('[IdentityController] alias $value available=$available');
    } catch (e) {
      debugPrint('[IdentityController] alias check error: $e');
      AppToast.error('Could not check alias availability.');
      aliasStatus.value = AliasStatus.idle;
    }
  }

  void togglePinVisibility() => pinVisible.toggle();
  String? validateAlias(String? value) => Validators.validateAlias(value);
  String? validatePin(String? value) => Validators.validatePin(value);

  void goToLogin() => Get.offAllNamed(AppRoutes.login);

  Future<void> enterOpenUp() async {
    debugPrint('[IdentityController] enterOpenUp (signup) called');
    if (!formKey.currentState!.validate()) return;

    if (aliasStatus.value == AliasStatus.taken) {
      AppToast.error('This alias is taken. Try another or log in.');
      return;
    }

    // If not yet checked (user skipped focus-out), check now
    if (aliasStatus.value == AliasStatus.idle) {
      await _checkAlias();
      if (aliasStatus.value == AliasStatus.taken) {
        AppToast.error('This alias is taken. Try another or log in.');
        return;
      }
    }

    isLoading.value = true;
    try {
      final deviceId = await _deviceRepo.getDeviceId();
      debugPrint('[IdentityController] deviceId=$deviceId — calling signup API');

      await _userRepo.signup(
        deviceId: deviceId,
        alias: aliasController.text.trim(),
        pin: pinController.text,
      );

      debugPrint('[IdentityController] Signup success — navigating to Home');
      _deviceRepo.initDevice().ignore();
      Get.offAllNamed(AppRoutes.home);
    } on AlreadyRegisteredException {
      debugPrint('[IdentityController] AlreadyRegisteredException — prompt login');
      AppToast.error('This alias is taken. Try another or log in.');
    } on AppException catch (e) {
      debugPrint('[IdentityController] AppException: ${e.message}');
      AppToast.error(e.message);
    } catch (e) {
      debugPrint('[IdentityController] Unexpected error: $e');
      AppToast.error('Signup failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
