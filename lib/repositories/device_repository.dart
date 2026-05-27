// lib/repositories/device_repository.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/device_utils.dart';
import '../models/device_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class DeviceRepository extends GetxService {
  late final ApiService _apiService;
  late final StorageService _storage;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[DeviceRepository] onInit');
    _apiService = Get.find<ApiService>();
    _storage = Get.find<StorageService>();
  }

  /// Returns the stored device ID, or generates and persists a new one.
  Future<String> getDeviceId() async {
    debugPrint('[DeviceRepository] getDeviceId called');
    final id = await DeviceUtils.getOrCreateDeviceId(_storage);
    debugPrint('[DeviceRepository] deviceId = $id');
    return id;
  }

  /// Initializes the device session with the backend.
  /// Falls back to cached values on network failure.
  Future<DeviceModel> initDevice() async {
    debugPrint('[DeviceRepository] initDevice called');
    try {
      final deviceId = await getDeviceId();
      debugPrint('[DeviceRepository] Calling API initDevice with deviceId=$deviceId');

      final model = await _apiService.initDevice(deviceId);
      debugPrint(
          '[DeviceRepository] initDevice API success → messagesLeft=${model.messagesLeft}, isPremium=${model.isPremium}');

      // Persist the response
      await _storage.setMessagesLeft(model.messagesLeft);
      await _storage.setIsPremium(model.isPremium);

      return model;
    } on AppException catch (e) {
      debugPrint('[DeviceRepository] initDevice AppException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[DeviceRepository] initDevice network/unknown error: $e — using cached values');
      // Return cached values if network fails
      final left = await _storage.getMessagesLeft();
      final premium = await _storage.getIsPremium();
      debugPrint('[DeviceRepository] Using cache: messagesLeft=$left, isPremium=$premium');
      return DeviceModel(
        messagesLeft: left ?? 0,
        isPremium: premium,
      );
    }
  }

  /// Deducts a message credit. Throws [PaywallException] on 403.
  Future<DeductResponse> deductMessage() async {
    debugPrint('[DeviceRepository] deductMessage called');
    try {
      final deviceId = await getDeviceId();
      debugPrint('[DeviceRepository] Calling API deductMessage with deviceId=$deviceId');

      final result = await _apiService.deductMessage(deviceId);
      debugPrint(
          '[DeviceRepository] deductMessage result → allowed=${result.allowed}, messagesLeft=${result.messagesLeft}');

      if (result.allowed && result.messagesLeft != null) {
        await _storage.setMessagesLeft(result.messagesLeft!);
      }

      return result;
    } catch (e) {
      debugPrint('[DeviceRepository] deductMessage error: $e');
      rethrow;
    }
  }

  Future<int> getCachedMessagesLeft() async {
    final val = await _storage.getMessagesLeft() ?? 0;
    debugPrint('[DeviceRepository] getCachedMessagesLeft = $val');
    return val;
  }

  Future<bool> getCachedIsPremium() async {
    final val = await _storage.getIsPremium();
    debugPrint('[DeviceRepository] getCachedIsPremium = $val');
    return val;
  }
}
