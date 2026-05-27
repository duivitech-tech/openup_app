// lib/services/api_service.dart

import 'package:dio/dio.dart';
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
    _dioClient = Get.find<DioClient>();
  }

  Dio get _dio => _dioClient.dio;

  // ─── Device ──────────────────────────────────────────────────────────────────

  /// POST /api/device/init — initializes or refreshes device session
  Future<DeviceModel> initDevice(String deviceId) async {
    try {
      final response = await _dio.post(
        ApiConstants.deviceInit,
        data: {'deviceId': deviceId},
      );
      return DeviceModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _toDomainError(e);
    }
  }

  /// POST /api/device/deduct — deducts one message credit
  Future<DeductResponse> deductMessage(String deviceId) async {
    try {
      final response = await _dio.post(
        ApiConstants.deviceDeduct,
        data: {'deviceId': deviceId},
      );
      return DeductResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw const PaywallException();
      }
      throw _toDomainError(e);
    }
  }

  // ─── Payment ─────────────────────────────────────────────────────────────────

  /// POST /api/payment/initiate — creates PhonePe payment session
  Future<String> initiatePayment(String deviceId, String planType) async {
    try {
      final response = await _dio.post(
        ApiConstants.paymentInitiate,
        data: {'deviceId': deviceId, 'planType': planType},
      );
      final data = response.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;
      if (!success) {
        throw const ServerException('Payment initiation failed');
      }
      return data['paymentUrl'] as String;
    } on DioException catch (e) {
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
      return RegisterPremiumResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final data = e.response?.data as Map<String, dynamic>?;
        final err = data?['error'] as String?;
        if (err != null && err.contains('already registered')) {
          throw const AlreadyRegisteredException();
        }
        throw ServerException(err ?? 'Registration failed', statusCode: 400);
      }
      if (e.response?.statusCode == 402) {
        throw const NoPaymentException();
      }
      throw _toDomainError(e);
    }
  }

  /// GET /api/user/check-name
  Future<bool> checkNameAvailability(String name) async {
    try {
      final response = await _dio.get(
        ApiConstants.checkName,
        queryParameters: {'name': name},
      );
      final data = response.data as Map<String, dynamic>;
      return data['available'] as bool? ?? false;
    } on DioException catch (e) {
      throw _toDomainError(e);
    }
  }

  // ─── Error Mapping ───────────────────────────────────────────────────────────

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
