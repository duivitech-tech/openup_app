// lib/services/storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';

class StorageService extends GetxService {
  late final FlutterSecureStorage _storage;

  @override
  void onInit() {
    super.onInit();
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }

  // ─── Generic Read/Write ──────────────────────────────────────────────────────

  Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw StorageException('Failed to read $key: $e');
    }
  }

  Future<void> setString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw StorageException('Failed to write $key: $e');
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw StorageException('Failed to delete $key: $e');
    }
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
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

  /// Clears all user data but preserves the device ID
  Future<void> clearUserData() async {
    final deviceId = await getDeviceId();
    await deleteAll();
    if (deviceId != null) {
      await setDeviceId(deviceId);
    }
  }
}
