// lib/repositories/user_repository.dart

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
    _apiService = Get.find<ApiService>();
    _storage = Get.find<StorageService>();
  }

  /// Loads the current user from local storage.
  /// Returns null if no identity has been set up.
  Future<UserModel?> loadUserFromStorage() async {
    final alias = await _storage.getNickname();
    if (alias == null || alias.isEmpty) return null;

    return UserModel.fromStorage(
      alias: alias,
      generatedUsername: await _storage.getGeneratedUsername(),
      isPremiumStr: (await _storage.getIsPremium()) ? 'true' : 'false',
      planType: await _storage.getPlanType(),
      expiryDate: await _storage.getExpiryDate(),
    );
  }

  /// Saves alias and PIN locally. No API call — free tier setup only.
  Future<void> saveLocalIdentity(String alias, String pin) async {
    await _storage.setNickname(alias);
    await _storage.setPin(pin);
  }

  /// Registers a premium account after payment.
  /// Throws [AlreadyRegisteredException] or [NoPaymentException] on failures.
  Future<UserModel> registerPremium({
    required String deviceId,
    required String name,
    required String pin,
    required String planType,
  }) async {
    try {
      final response = await _apiService.registerPremium(
        deviceId: deviceId,
        name: name,
        password: pin,
        planType: planType,
      );

      if (!response.success) {
        throw ServerException(response.error ?? 'Registration failed');
      }

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
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Registration failed: $e');
    }
  }

  /// Checks if a username is available on the backend.
  Future<bool> isNameAvailable(String name) async {
    return _apiService.checkNameAvailability(name);
  }

  /// Clears all user data (alias, pin, premium, etc.) but keeps deviceId.
  Future<void> clearAllData() async {
    await _storage.clearUserData();
  }
}
