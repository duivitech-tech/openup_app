// lib/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import '../core/constants/api_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/app_update_model.dart';
import '../models/device_model.dart';
import '../models/user_model.dart';
import '../network/dio_client.dart';

class ApiService extends GetxService {
  late final DioClient _dioClient;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[ApiService] onInit — base URL: ${ApiConstants.baseUrl}');
    _dioClient = Get.find<DioClient>();
  }

  Dio get _dio => _dioClient.dio;

  Options _bearer(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  // ─── Auth ─────────────────────────────────────────────────────────────────────

  /// POST /api/auth/signup → { success, userId, accessToken, refreshToken }
  Future<AuthResponse> signup({
    required String deviceId,
    required String alias,
    required String pin,
  }) async {
    debugPrint('[ApiService] POST ${ApiConstants.authSignup} — alias=$alias');
    try {
      final response = await _dio.post(
        ApiConstants.authSignup,
        data: {'deviceId': deviceId, 'name': alias, 'password': pin},
      );
      debugPrint('[ApiService] signup response: ${response.statusCode} ${response.data}');
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[ApiService] signup DioException: ${e.response?.statusCode} ${e.response?.data}');
      if (e.response?.statusCode == 409) throw const AlreadyRegisteredException();
      throw _toDomainError(e);
    }
  }

  /// POST /api/auth/login → { success, userId, name, accessToken, refreshToken, ... }
  Future<AuthResponse> login({
    required String deviceId,
    required String alias,
    required String pin,
  }) async {
    debugPrint('[ApiService] POST ${ApiConstants.authLogin} — alias=$alias');
    try {
      final response = await _dio.post(
        ApiConstants.authLogin,
        data: {'name': alias, 'password': pin},
      );
      debugPrint('[ApiService] login response: ${response.statusCode} ${response.data}');
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[ApiService] login DioException: ${e.response?.statusCode} ${e.response?.data}');
      if (e.response?.statusCode == 401) throw const InvalidCredentialsException();
      if (e.response?.statusCode == 404) throw const UserNotFoundException();
      throw _toDomainError(e);
    }
  }

  /// POST /api/auth/refresh → { accessToken }
  Future<String> refreshAccessToken(String refreshToken) async {
    debugPrint('[ApiService] POST ${ApiConstants.authRefresh}');
    try {
      final response = await _dio.post(
        ApiConstants.authRefresh,
        data: {'refreshToken': refreshToken},
      );
      final newToken = (response.data as Map<String, dynamic>)['accessToken'] as String;
      debugPrint('[ApiService] refreshAccessToken success');
      return newToken;
    } on DioException catch (e) {
      debugPrint('[ApiService] refreshAccessToken DioException: ${e.response?.statusCode}');
      if (e.response?.statusCode == 401) throw const SessionExpiredException();
      throw _toDomainError(e);
    }
  }

  /// GET /api/user/profile — Bearer accessToken
  Future<UserModel> fetchProfile(String accessToken) async {
    debugPrint('[ApiService] GET ${ApiConstants.userProfile}');
    try {
      final response = await _dio.get(
        ApiConstants.userProfile,
        options: _bearer(accessToken),
      );
      debugPrint('[ApiService] fetchProfile response: ${response.statusCode} ${response.data}');
      return UserModel.fromProfileJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[ApiService] fetchProfile DioException: ${e.response?.statusCode}');
      if (e.response?.statusCode == 401) throw const SessionExpiredException();
      throw _toDomainError(e);
    }
  }

  /// POST /api/auth/logout — Bearer accessToken
  Future<void> logout(String accessToken) async {
    debugPrint('[ApiService] POST ${ApiConstants.authLogout}');
    try {
      await _dio.post(
        ApiConstants.authLogout,
        options: _bearer(accessToken),
      );
      debugPrint('[ApiService] logout success');
    } on DioException catch (e) {
      debugPrint('[ApiService] logout DioException: ${e.response?.statusCode} — ignoring');
      // Non-fatal — always clear local data regardless
    }
  }

  // ─── Device ───────────────────────────────────────────────────────────────────

  /// POST /api/device/init → { registered: true }
  Future<DeviceModel> initDevice(String deviceId) async {
    debugPrint('[ApiService] POST ${ApiConstants.deviceInit} — deviceId=$deviceId');
    try {
      final response = await _dio.post(
        ApiConstants.deviceInit,
        data: {'deviceId': deviceId},
      );
      debugPrint('[ApiService] initDevice response: ${response.statusCode} ${response.data}');
      return DeviceModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[ApiService] initDevice DioException: ${e.response?.statusCode}');
      throw _toDomainError(e);
    }
  }

  /// POST /api/device/deduct — Bearer accessToken, no body
  Future<DeductResponse> deductMessage(String accessToken) async {
    debugPrint('[ApiService] POST ${ApiConstants.deviceDeduct}');
    try {
      final response = await _dio.post(
        ApiConstants.deviceDeduct,
        options: _bearer(accessToken),
      );
      debugPrint('[ApiService] deductMessage response: ${response.statusCode} ${response.data}');
      return DeductResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[ApiService] deductMessage DioException: ${e.response?.statusCode}');
      if (e.response?.statusCode == 403) throw const PaywallException();
      throw _toDomainError(e);
    }
  }

  // ─── Payment ─────────────────────────────────────────────────────────────────

  /// POST /api/payment/initiate — Bearer accessToken
  Future<String> initiatePayment(String accessToken, String planType) async {
    debugPrint('[ApiService] POST ${ApiConstants.paymentInitiate} — planType=$planType');
    try {
      final response = await _dio.post(
        ApiConstants.paymentInitiate,
        data: {'planType': planType},
        options: _bearer(accessToken),
      );
      debugPrint('[ApiService] initiatePayment response: ${response.statusCode}');
      final data = response.data as Map<String, dynamic>;
      if (!(data['success'] as bool? ?? false)) {
        throw const ServerException('Payment initiation failed');
      }
      return data['paymentUrl'] as String;
    } on DioException catch (e) {
      debugPrint('[ApiService] initiatePayment DioException: ${e.response?.statusCode}');
      throw _toDomainError(e);
    }
  }

  // ─── User ─────────────────────────────────────────────────────────────────────

  /// POST /api/user/register-premium
  Future<RegisterPremiumResponse> registerPremium({
    required String deviceId,
    required String name,
    required String password,
    required String planType,
  }) async {
    debugPrint('[ApiService] POST ${ApiConstants.registerPremium}');
    try {
      final response = await _dio.post(
        ApiConstants.registerPremium,
        data: {'deviceId': deviceId, 'name': name, 'password': password, 'planType': planType},
      );
      debugPrint('[ApiService] registerPremium response: ${response.statusCode}');
      return RegisterPremiumResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[ApiService] registerPremium DioException: ${e.response?.statusCode} ${e.response?.data}');
      if (e.response?.statusCode == 400) {
        final data = e.response?.data as Map<String, dynamic>?;
        final err = data?['error'] as String?;
        if (err != null && err.contains('already registered')) throw const AlreadyRegisteredException();
        throw ServerException(err ?? 'Registration failed', statusCode: 400);
      }
      if (e.response?.statusCode == 402) throw const NoPaymentException();
      throw _toDomainError(e);
    }
  }

  /// GET /api/user/check-name
  Future<bool> checkNameAvailability(String name) async {
    debugPrint('[ApiService] GET ${ApiConstants.checkName} — name=$name');
    try {
      final response = await _dio.get(
        ApiConstants.checkName,
        queryParameters: {'name': name},
      );
      final available = (response.data as Map<String, dynamic>)['available'] as bool? ?? false;
      debugPrint('[ApiService] checkName: available=$available');
      return available;
    } on DioException catch (e) {
      debugPrint('[ApiService] checkName DioException: ${e.response?.statusCode}');
      throw _toDomainError(e);
    }
  }

  // ─── App ──────────────────────────────────────────────────────────────────────

  /// GET /api/app/update/check?platform=android&version=1.0.0&versionCode=1
  Future<AppUpdateModel> checkAppUpdate({
    required String platform,
    required String version,
    required int versionCode,
  }) async {
    debugPrint('[ApiService] GET ${ApiConstants.checkAppUpdate} — platform=$platform, version=$version, versionCode=$versionCode');
    try {
      final response = await _dio.get(
        ApiConstants.checkAppUpdate,
        queryParameters: {
          'platform': platform,
          'version': version,
          'versionCode': versionCode,
        },
      );
      debugPrint('[ApiService] checkAppUpdate response: ${response.statusCode} ${response.data}');
      return AppUpdateModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[ApiService] checkAppUpdate DioException: ${e.response?.statusCode} ${e.response?.data}');
      throw _toDomainError(e);
    }
  }

  // ─── Error Mapping ────────────────────────────────────────────────────────────

  AppException _toDomainError(DioException e) {
    if (e.error is AppException) return e.error as AppException;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException('Connection timed out');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException('No internet connection');
    }
    return ServerException(
      e.response?.data?.toString() ?? e.message ?? 'Unknown error',
      statusCode: e.response?.statusCode,
    );
  }
}
