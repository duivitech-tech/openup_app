// lib/core/utils/device_utils.dart

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../../services/storage_service.dart';

class DeviceUtils {
  DeviceUtils._();

  /// Returns the unique device ID.
  /// Reads from storage first; generates and persists if not found.
  /// Priority: Android ID → iOS vendor ID → UUID fallback.
  static Future<String> getOrCreateDeviceId(StorageService storage) async {
    // Return cached value if already stored
    final stored = await storage.getString(AppConstants.keyDeviceId);
    if (stored != null && stored.isNotEmpty) return stored;

    String deviceId;
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        deviceId = android.id;
      } else if (Platform.isIOS) {
        final ios = await info.iosInfo;
        deviceId = ios.identifierForVendor ?? _generateUuid();
      } else {
        deviceId = _generateUuid();
      }
    } catch (_) {
      // Fallback for any device_info error
      deviceId = _generateUuid();
    }

    await storage.setString(AppConstants.keyDeviceId, deviceId);
    return deviceId;
  }

  static String _generateUuid() => const Uuid().v4();
}
