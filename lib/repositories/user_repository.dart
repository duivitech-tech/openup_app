// lib/repositories/user_repository.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../core/errors/app_exceptions.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class UserRepository extends GetxService {
  late final ApiService _apiService;
  late final StorageService _storage;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[UserRepository] onInit');
    _apiService = Get.find<ApiService>();
    _storage = Get.find<StorageService>();
  }

  /// Loads the current user from local storage.
  Future<UserModel?> loadUserFromStorage() async {
    debugPrint('[UserRepository] loadUserFromStorage called');
    final alias = await _storage.getNickname();
    if (alias == null || alias.isEmpty) {
      debugPrint('[UserRepository] No alias in storage — returning null');
      return null;
    }

    final user = UserModel.fromStorage(
      alias: alias,
      generatedUsername: await _storage.getGeneratedUsername(),
      isPremiumStr: (await _storage.getIsPremium()) ? 'true' : 'false',
      planType: await _storage.getPlanType(),
      expiryDate: await _storage.getExpiryDate(),
    );
    debugPrint('[UserRepository] Loaded user: alias=${user.alias}, isPremium=${user.isPremium}');
    return user;
  }

  /// Saves alias and PIN locally. No API call — free tier setup only.
  Future<void> saveLocalIdentity(String alias, String pin) async {
    debugPrint('[UserRepository] saveLocalIdentity: alias=$alias');
    await _storage.setNickname(alias);
    await _storage.setPin(pin);
    debugPrint('[UserRepository] saveLocalIdentity done');
  }

  /// Registers a premium account after payment.
  Future<UserModel> registerPremium({
    required String deviceId,
    required String name,
    required String pin,
    required String planType,
  }) async {
    debugPrint('[UserRepository] registerPremium: deviceId=$deviceId, name=$name, planType=$planType');
    try {
      final response = await _apiService.registerPremium(
        deviceId: deviceId,
        name: name,
        password: pin,
        planType: planType,
      );

      if (!response.success) {
        debugPrint('[UserRepository] registerPremium: API returned success=false — ${response.error}');
        throw ServerException(response.error ?? 'Registration failed');
      }

      debugPrint('[UserRepository] registerPremium success — generatedUsername=${response.generatedUsername}');

      // Persist premium account data
      await _storage.setGeneratedUsername(response.generatedUsername ?? '');
      await _storage.setExpiryDate(response.expiryDate ?? '');
      await _storage.setIsPremium(true);
      await _storage.setNickname(name);

      return UserModel(
        alias: name,
        generatedUsername: response.generatedUsername,
        isPremium: true,
        planType: planType,
        expiryDate: response.expiryDate,
      );
    } on AppException catch (e) {
      debugPrint('[UserRepository] registerPremium AppException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[UserRepository] registerPremium unexpected error: $e');
      throw ServerException('Registration failed: $e');
    }
  }

  /// Checks if a username is available on the backend.
  Future<bool> isNameAvailable(String name) async {
    debugPrint('[UserRepository] isNameAvailable: name=$name');
    final result = await _apiService.checkNameAvailability(name);
    debugPrint('[UserRepository] isNameAvailable result: $result');
    return result;
  }

  /// Clears all user data (alias, pin, premium, etc.) but keeps deviceId.
  Future<void> clearAllData() async {
    debugPrint('[UserRepository] clearAllData called');
    await _storage.clearUserData();
    debugPrint('[UserRepository] clearAllData done');
  }
}
