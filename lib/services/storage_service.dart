// lib/services/storage_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';

class StorageService extends GetxService {
  late final FlutterSecureStorage _storage;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[StorageService] Initializing FlutterSecureStorage…');
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
    debugPrint('[StorageService] Ready');
  }

  // ─── Generic Read/Write ──────────────────────────────────────────────────────

  Future<String?> getString(String key) async {
    try {
      final value = await _storage.read(key: key);
      debugPrint('[Storage] READ  "$key" → ${value != null ? '"$value"' : 'null'}');
      return value;
    } catch (e) {
      debugPrint('[Storage] ERROR reading "$key": $e');
      throw StorageException('Failed to read $key: $e');
    }
  }

  Future<void> setString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      debugPrint('[Storage] WRITE "$key" = "$value"');
    } catch (e) {
      debugPrint('[Storage] ERROR writing "$key": $e');
      throw StorageException('Failed to write $key: $e');
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      debugPrint('[Storage] DELETE "$key"');
    } catch (e) {
      debugPrint('[Storage] ERROR deleting "$key": $e');
      throw StorageException('Failed to delete $key: $e');
    }
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      debugPrint('[Storage] DELETE ALL');
    } catch (e) {
      debugPrint('[Storage] ERROR clearing all: $e');
      throw StorageException('Failed to clear storage: $e');
    }
  }

  // ─── Typed Helpers ───────────────────────────────────────────────────────────

  Future<String?> getDeviceId() => getString(AppConstants.keyDeviceId);
  Future<void> setDeviceId(String id) =>
      setString(AppConstants.keyDeviceId, id);

  Future<int?> getMessagesLeft() async {
    final val = await getString(AppConstants.keyMessagesLeft);
    return val != null ? int.tryParse(val) : null;
  }

  Future<void> setMessagesLeft(int count) =>
      setString(AppConstants.keyMessagesLeft, count.toString());

  Future<bool> getIsPremium() async {
    final val = await getString(AppConstants.keyIsPremium);
    return val == 'true';
  }

  Future<void> setIsPremium(bool value) =>
      setString(AppConstants.keyIsPremium, value.toString());

  Future<String?> getNickname() => getString(AppConstants.keyNickname);
  Future<void> setNickname(String name) =>
      setString(AppConstants.keyNickname, name);

  Future<String?> getGeneratedUsername() =>
      getString(AppConstants.keyGeneratedUsername);
  Future<void> setGeneratedUsername(String username) =>
      setString(AppConstants.keyGeneratedUsername, username);

  Future<String?> getPlanType() => getString(AppConstants.keyPlanType);
  Future<void> setPlanType(String plan) =>
      setString(AppConstants.keyPlanType, plan);

  Future<String?> getExpiryDate() => getString(AppConstants.keyExpiryDate);
  Future<void> setExpiryDate(String date) =>
      setString(AppConstants.keyExpiryDate, date);

  Future<String?> getPin() => getString(AppConstants.keyPin);
  Future<void> setPin(String pin) => setString(AppConstants.keyPin, pin);

  Future<String?> getAuthToken() => getString(AppConstants.keyAuthToken);
  Future<void> setAuthToken(String token) =>
      setString(AppConstants.keyAuthToken, token);
  Future<void> deleteAuthToken() => delete(AppConstants.keyAuthToken);

  Future<String?> getUserId() => getString(AppConstants.keyUserId);
  Future<void> setUserId(String id) => setString(AppConstants.keyUserId, id);
  Future<void> deleteUserId() => delete(AppConstants.keyUserId);

  /// Clears all user data but preserves the device ID.
  Future<void> clearUserData() async {
    debugPrint('[Storage] clearUserData — preserving deviceId');
    final deviceId = await getDeviceId();
    await deleteAll();
    if (deviceId != null) {
      await setDeviceId(deviceId);
    }
    debugPrint('[Storage] clearUserData done');
  }
}
