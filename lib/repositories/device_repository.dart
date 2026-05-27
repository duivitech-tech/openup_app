// lib/repositories/device_repository.dart

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
    _apiService = Get.find<ApiService>();
    _storage = Get.find<StorageService>();
  }

  /// Returns the stored device ID, or generates and persists a new one.
  Future<String> getDeviceId() async {
    return DeviceUtils.getOrCreateDeviceId(_storage);
  }

  /// Initializes the device session with the backend.
  /// Persists messagesLeft and isPremium to storage.
  Future<DeviceModel> initDevice() async {
    try {
      final deviceId = await getDeviceId();
      final model = await _apiService.initDevice(deviceId);

      // Persist the response
      await _storage.setMessagesLeft(model.messagesLeft);
      await _storage.setIsPremium(model.isPremium);

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      // Return cached values if network fails
      final left = await _storage.getMessagesLeft();
      final premium = await _storage.getIsPremium();
      return DeviceModel(
        messagesLeft: left ?? 0,
        isPremium: premium,
      );
    }
  }

  /// Deducts a message credit. Throws [PaywallException] on 403.
  /// Returns updated messages left count.
  Future<DeductResponse> deductMessage() async {
    final deviceId = await getDeviceId();
    final result = await _apiService.deductMessage(deviceId);

    // Update local count on success
    if (result.allowed && result.messagesLeft != null) {
      await _storage.setMessagesLeft(result.messagesLeft!);
    }

    return result;
  }

  /// Returns cached messages left count from storage.
  Future<int> getCachedMessagesLeft() async {
    return await _storage.getMessagesLeft() ?? 0;
  }

  /// Returns cached premium status from storage.
  Future<bool> getCachedIsPremium() async {
    return await _storage.getIsPremium();
  }
}
