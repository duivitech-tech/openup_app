// lib/core/utils/device_utils.dart

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../../services/storage_service.dart';

class DeviceUtils {
  DeviceUtils._();

  /// Returns the unique device ID.
  /// Reads from storage first; generates and persists if not found.
  /// Priority: Stored ID → Android ID → iOS vendor ID → UUID fallback.
  static Future<String> getOrCreateDeviceId(StorageService storage) async {
    // Return cached value if already stored
    final stored = await storage.getString(AppConstants.keyDeviceId);
    if (stored != null && stored.isNotEmpty) {
      debugPrint('[DeviceUtils] Returning cached deviceId: $stored');
      return stored;
    }

    debugPrint('[DeviceUtils] No cached deviceId — generating new one…');
    String deviceId;
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        deviceId = android.id;
        debugPrint('[DeviceUtils] Android device ID: $deviceId');
      } else if (Platform.isIOS) {
        final ios = await info.iosInfo;
        deviceId = ios.identifierForVendor ?? _generateUuid();
        debugPrint('[DeviceUtils] iOS vendor ID: $deviceId');
      } else {
        deviceId = _generateUuid();
        debugPrint('[DeviceUtils] Non-mobile platform — UUID: $deviceId');
      }
    } catch (e) {
      deviceId = _generateUuid();
      debugPrint('[DeviceUtils] device_info error ($e) — fallback UUID: $deviceId');
    }

    await storage.setString(AppConstants.keyDeviceId, deviceId);
    debugPrint('[DeviceUtils] Saved new deviceId: $deviceId');
    return deviceId;
  }

  static String _generateUuid() => const Uuid().v4();
}
