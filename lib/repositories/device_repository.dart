// lib/repositories/device_repository.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/device_utils.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/device_model.dart';

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
    final id = await DeviceUtils.getOrCreateDeviceId(_storage);
    debugPrint('[DeviceRepository] deviceId = $id');
    return id;
  }

  /// Registers the device with the backend. Response is just { registered: true }.
  /// Fire-and-forget — quota/premium data comes from profile API.
  Future<void> initDevice() async {
    debugPrint('[DeviceRepository] initDevice called');
    try {
      final deviceId = await getDeviceId();
      final result = await _apiService.initDevice(deviceId);
      debugPrint('[DeviceRepository] initDevice success — registered=${result.registered}');
    } catch (e) {
      debugPrint('[DeviceRepository] initDevice error (ignoring): $e');
    }
  }

  /// Deducts a message credit using JWT. Throws [PaywallException] on 403.
  Future<DeductResponse> deductMessage() async {
    debugPrint('[DeviceRepository] deductMessage called');
    final accessToken = await _storage.getAuthToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const ServerException('No access token for deduct');
    }
    try {
      final result = await _apiService.deductMessage(accessToken);
      debugPrint('[DeviceRepository] deductMessage → allowed=${result.allowed}, left=${result.messagesLeft}');
      return result;
    } catch (e) {
      debugPrint('[DeviceRepository] deductMessage error: $e');
      rethrow;
    }
  }
}
