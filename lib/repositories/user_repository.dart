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

  // ─── Auth ─────────────────────────────────────────────────────────────────────

  /// Signs up a new user. Stores userId + profile locally on success.
  Future<UserModel> signup({
    required String deviceId,
    required String alias,
    required String pin,
  }) async {
    debugPrint('[UserRepository] signup: alias=$alias');
    try {
      final response = await _apiService.signup(
        deviceId: deviceId,
        alias: alias,
        pin: pin,
      );

      if (!response.success) {
        debugPrint('[UserRepository] signup: success=false — ${response.error}');
        throw ServerException(response.error ?? 'Signup failed');
      }

      debugPrint('[UserRepository] signup success — userId=${response.userId}');
      await _persistAuthSession(
        token: response.token ?? '',
        userId: response.userId ?? '',
        alias: alias,
        pin: pin,
        user: response.user,
      );

      return response.user ?? UserModel(alias: alias);
    } on AppException catch (e) {
      debugPrint('[UserRepository] signup AppException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[UserRepository] signup unexpected error: $e');
      throw ServerException('Signup failed: $e');
    }
  }

  /// Logs in an existing user. Stores token + profile locally on success.
  Future<UserModel> login({
    required String deviceId,
    required String alias,
    required String pin,
  }) async {
    debugPrint('[UserRepository] login: alias=$alias');
    try {
      final response = await _apiService.login(
        deviceId: deviceId,
        alias: alias,
        pin: pin,
      );

      if (!response.success) {
        debugPrint('[UserRepository] login: success=false — ${response.error}');
        throw ServerException(response.error ?? 'Login failed');
      }

      debugPrint('[UserRepository] login success — userId=${response.userId}');
      await _persistAuthSession(
        token: response.token ?? '',
        userId: response.userId ?? '',
        alias: alias,
        pin: pin,
        user: response.user,
      );

      return response.user ?? UserModel(alias: alias);
    } on AppException catch (e) {
      debugPrint('[UserRepository] login AppException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[UserRepository] login unexpected error: $e');
      throw ServerException('Login failed: $e');
    }
  }

  /// Fetches fresh profile from backend using stored userId.
  /// Falls back to storage on network failure.
  Future<UserModel?> fetchProfile() async {
    debugPrint('[UserRepository] fetchProfile called');
    final userId = await _storage.getUserId();
    if (userId == null || userId.isEmpty) {
      debugPrint('[UserRepository] fetchProfile: no userId — returning storage fallback');
      return loadUserFromStorage();
    }

    try {
      final user = await _apiService.fetchProfile(userId);
      debugPrint('[UserRepository] fetchProfile success: ${user.alias}, isPremium=${user.isPremium}');

      // Persist fresh values
      await _storage.setNickname(user.alias);
      await _storage.setIsPremium(user.isPremium);
      if (user.messagesLeft != null) {
        await _storage.setMessagesLeft(user.messagesLeft!);
      }
      if (user.planType != null) await _storage.setPlanType(user.planType!);
      if (user.expiryDate != null) await _storage.setExpiryDate(user.expiryDate!);
      if (user.generatedUsername != null) {
        await _storage.setGeneratedUsername(user.generatedUsername!);
      }

      return user;
    } on SessionExpiredException {
      debugPrint('[UserRepository] fetchProfile: session expired — clearing userId');
      await _storage.deleteUserId();
      return loadUserFromStorage();
    } catch (e) {
      debugPrint('[UserRepository] fetchProfile network error ($e) — using cache');
      return loadUserFromStorage();
    }
  }

  /// Logs out: hits logout API then clears all local data.
  Future<void> logout() async {
    debugPrint('[UserRepository] logout called');
    final userId = await _storage.getUserId();
    if (userId != null && userId.isNotEmpty) {
      try {
        await _apiService.logout(userId);
        debugPrint('[UserRepository] logout API success');
      } catch (e) {
        debugPrint('[UserRepository] logout API error (ignoring): $e');
      }
    }
    await _storage.deleteAuthToken();
    await _storage.deleteUserId();
    await _storage.clearUserData();
    debugPrint('[UserRepository] logout: token + userId + user data cleared');
  }

  // ─── Local storage ────────────────────────────────────────────────────────────

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
    debugPrint('[UserRepository] Loaded: alias=${user.alias}, isPremium=${user.isPremium}');
    return user;
  }

  /// Saves alias and PIN locally only. No API call.
  Future<void> saveLocalIdentity(String alias, String pin) async {
    debugPrint('[UserRepository] saveLocalIdentity: alias=$alias');
    await _storage.setNickname(alias);
    await _storage.setPin(pin);
  }

  /// Registers a premium account after payment.
  Future<UserModel> registerPremium({
    required String deviceId,
    required String name,
    required String pin,
    required String planType,
  }) async {
    debugPrint('[UserRepository] registerPremium: name=$name, planType=$planType');
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

  Future<bool> isNameAvailable(String name) async {
    final result = await _apiService.checkNameAvailability(name);
    debugPrint('[UserRepository] isNameAvailable($name): $result');
    return result;
  }

  Future<void> clearAllData() async {
    debugPrint('[UserRepository] clearAllData called');
    await _storage.deleteAuthToken();
    await _storage.deleteUserId();
    await _storage.clearUserData();
  }

  // ─── Private helpers ──────────────────────────────────────────────────────────

  Future<void> _persistAuthSession({
    required String token,
    required String userId,
    required String alias,
    required String pin,
    UserModel? user,
  }) async {
    if (token.isNotEmpty) await _storage.setAuthToken(token);
    if (userId.isNotEmpty) await _storage.setUserId(userId);
    await _storage.setNickname(alias);
    await _storage.setPin(pin);
    if (user != null) {
      await _storage.setIsPremium(user.isPremium);
      if (user.planType != null) await _storage.setPlanType(user.planType!);
      if (user.expiryDate != null) await _storage.setExpiryDate(user.expiryDate!);
      if (user.generatedUsername != null) {
        await _storage.setGeneratedUsername(user.generatedUsername!);
      }
      if (user.messagesLeft != null) {
        await _storage.setMessagesLeft(user.messagesLeft!);
      }
    }
    debugPrint('[UserRepository] Auth session persisted for alias=$alias, userId=$userId');
  }
}
