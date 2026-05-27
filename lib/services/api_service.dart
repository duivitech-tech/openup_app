// lib/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import '../core/constants/api_constants.dart';
import '../core/errors/app_exceptions.dart';
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

  // ─── Device ──────────────────────────────────────────────────────────────────

  /// POST /api/device/init
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
      debugPrint('[ApiService] initDevice DioException: ${e.response?.statusCode} ${e.message}');
      throw _toDomainError(e);
    }
  }

  /// POST /api/device/deduct
  Future<DeductResponse> deductMessage(String deviceId) async {
    debugPrint('[ApiService] POST ${ApiConstants.deviceDeduct} — deviceId=$deviceId');
    try {
      final response = await _dio.post(
        ApiConstants.deviceDeduct,
        data: {'deviceId': deviceId},
      );
      debugPrint('[ApiService] deductMessage response: ${response.statusCode} ${response.data}');
      return DeductResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[ApiService] deductMessage DioException: ${e.response?.statusCode} ${e.message}');
      if (e.response?.statusCode == 403) {
        debugPrint('[ApiService] deductMessage → PaywallException (403)');
        throw const PaywallException();
      }
      throw _toDomainError(e);
    }
  }

  // ─── Payment ─────────────────────────────────────────────────────────────────

  /// POST /api/payment/initiate
  Future<String> initiatePayment(String deviceId, String planType) async {
    debugPrint('[ApiService] POST ${ApiConstants.paymentInitiate} — deviceId=$deviceId, planType=$planType');
    try {
      final response = await _dio.post(
        ApiConstants.paymentInitiate,
        data: {'deviceId': deviceId, 'planType': planType},
      );
      debugPrint('[ApiService] initiatePayment response: ${response.statusCode} ${response.data}');
      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;
      if (!success) {
        debugPrint('[ApiService] initiatePayment: success=false');
        throw const ServerException('Payment initiation failed');
      }
      final url = data['paymentUrl'] as String;
      debugPrint('[ApiService] initiatePayment: paymentUrl=$url');
      return url;
    } on DioException catch (e) {
      debugPrint('[ApiService] initiatePayment DioException: ${e.response?.statusCode} ${e.message}');
      throw _toDomainError(e);
    }
  }

  // ─── User ────────────────────────────────────────────────────────────────────

  /// POST /api/user/register-premium
  Future<RegisterPremiumResponse> registerPremium({
    required String deviceId,
    required String name,
    required String password,
    required String planType,
  }) async {
    debugPrint('[ApiService] POST ${ApiConstants.registerPremium} — deviceId=$deviceId, name=$name, planType=$planType');
    try {
      final response = await _dio.post(
        ApiConstants.registerPremium,
        data: {
          'deviceId': deviceId,
          'name': name,
          'password': password,
          'planType': planType,
        },
      );
      debugPrint('[ApiService] registerPremium response: ${response.statusCode} ${response.data}');
      return RegisterPremiumResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[ApiService] registerPremium DioException: ${e.response?.statusCode} ${e.response?.data} ${e.message}');
      if (e.response?.statusCode == 400) {
        final data = e.response?.data as Map<String, dynamic>?;
        final err = data?['error'] as String?;
        if (err != null && err.contains('already registered')) {
          debugPrint('[ApiService] registerPremium → AlreadyRegisteredException');
          throw const AlreadyRegisteredException();
        }
        throw ServerException(err ?? 'Registration failed', statusCode: 400);
      }
      if (e.response?.statusCode == 402) {
        debugPrint('[ApiService] registerPremium → NoPaymentException (402)');
        throw const NoPaymentException();
      }
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
      final data = response.data as Map<String, dynamic>;
      final available = data['available'] as bool? ?? false;
      debugPrint('[ApiService] checkName response: available=$available');
      return available;
    } on DioException catch (e) {
      debugPrint('[ApiService] checkName DioException: ${e.response?.statusCode} ${e.message}');
      throw _toDomainError(e);
    }
  }

  // ─── Error Mapping ───────────────────────────────────────────────────────────

  AppException _toDomainError(DioException e) {
    if (e.error is AppException) {
      debugPrint('[ApiService] Re-wrapping AppException from error field');
      return e.error as AppException;
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      debugPrint('[ApiService] → NetworkException (timeout)');
      return const NetworkException('Connection timed out');
    }
    if (e.type == DioExceptionType.connectionError) {
      debugPrint('[ApiService] → NetworkException (no connection)');
      return const NetworkException('No internet connection');
    }
    debugPrint('[ApiService] → ServerException: ${e.response?.statusCode}');
    return ServerException(
      e.response?.data?.toString() ?? e.message ?? 'Unknown error',
      statusCode: e.response?.statusCode,
    );
  }
}
