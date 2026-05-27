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
      if (!response.success) throw ServerException(response.error ?? 'Signup failed');
      await _persistSession(
        accessToken: response.accessToken ?? '',
        refreshToken: response.refreshToken ?? '',
        alias: alias,
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
      if (!response.success) throw ServerException(response.error ?? 'Login failed');
      await _persistSession(
        accessToken: response.accessToken ?? '',
        refreshToken: response.refreshToken ?? '',
        alias: alias,
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

  /// Fetches fresh profile using stored accessToken.
  /// The Dio interceptor handles 401 → auto-refresh → retry transparently.
  /// Falls back to cached nickname on network failure.
  Future<UserModel?> fetchProfile() async {
    debugPrint('[UserRepository] fetchProfile called');
    final accessToken = await _storage.getAuthToken();
    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('[UserRepository] fetchProfile: no accessToken — returning storage fallback');
      return loadUserFromStorage();
    }
    try {
      final user = await _apiService.fetchProfile(accessToken);
      debugPrint('[UserRepository] fetchProfile success: ${user.alias}, isPremium=${user.isPremium}');
      // Only cache the nickname for display — everything else comes from API
      await _storage.setNickname(user.alias);
      return user;
    } on SessionExpiredException {
      debugPrint('[UserRepository] fetchProfile: session expired — clearing tokens');
      await _clearTokens();
      return loadUserFromStorage();
    } catch (e) {
      debugPrint('[UserRepository] fetchProfile network error ($e) — using cache');
      return loadUserFromStorage();
    }
  }

  /// Logs out: invalidates refreshToken server-side, clears all local data.
  Future<void> logout() async {
    debugPrint('[UserRepository] logout called');
    final accessToken = await _storage.getAuthToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      try {
        await _apiService.logout(accessToken);
        debugPrint('[UserRepository] logout API success');
      } catch (e) {
        debugPrint('[UserRepository] logout API error (ignoring): $e');
      }
    }
    await _clearTokens();
    await _storage.clearUserData();
    debugPrint('[UserRepository] logout: all data cleared');
  }

  // ─── Local storage ────────────────────────────────────────────────────────────

  /// Returns a minimal UserModel from cached nickname only.
  Future<UserModel?> loadUserFromStorage() async {
    debugPrint('[UserRepository] loadUserFromStorage called');
    final alias = await _storage.getNickname();
    if (alias == null || alias.isEmpty) {
      debugPrint('[UserRepository] No alias in storage — returning null');
      return null;
    }
    return UserModel(alias: alias);
  }

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
      if (!response.success) throw ServerException(response.error ?? 'Registration failed');
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
    await _clearTokens();
    await _storage.clearUserData();
  }

  // ─── Private helpers ──────────────────────────────────────────────────────────

  Future<void> _persistSession({
    required String accessToken,
    required String refreshToken,
    required String alias,
  }) async {
    if (accessToken.isNotEmpty) await _storage.setAuthToken(accessToken);
    if (refreshToken.isNotEmpty) await _storage.setRefreshToken(refreshToken);
    await _storage.setNickname(alias);
    debugPrint('[UserRepository] Session persisted — alias=$alias');
  }

  Future<void> _clearTokens() async {
    await _storage.deleteAuthToken();
    await _storage.deleteRefreshToken();
  }
}
