// lib/repositories/app_update_repository.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/app_update_model.dart';
import '../services/api_service.dart';

class AppUpdateRepository extends GetxService {
  late final ApiService _apiService;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[AppUpdateRepository] onInit');
    _apiService = Get.find<ApiService>();
  }

  /// Calls GET /api/app/update/check and returns the parsed model.
  /// Returns null on any error so callers can fail silently.
  Future<AppUpdateModel?> checkForUpdate({
    required String platform,
    required String version,
    required int versionCode,
  }) async {
    debugPrint(
        '[AppUpdateRepository] checkForUpdate — platform=$platform, version=$version, versionCode=$versionCode');
    try {
      final result = await _apiService.checkAppUpdate(
        platform: platform,
        version: version,
        versionCode: versionCode,
      );
      debugPrint('[AppUpdateRepository] checkForUpdate result: $result');
      return result;
    } catch (e) {
      debugPrint('[AppUpdateRepository] checkForUpdate error (silent): $e');
      return null;
    }
  }
}
