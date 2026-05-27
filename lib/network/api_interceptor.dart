// lib/network/api_interceptor.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../core/errors/app_exceptions.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('┌─────────────────────────────────────────────────────');
    debugPrint('│ [HTTP] ➤ ${options.method} ${options.uri}');
    if (options.data != null) {
      debugPrint('│ [HTTP] Body: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      debugPrint('│ [HTTP] Params: ${options.queryParameters}');
    }
    debugPrint('└─────────────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('┌─────────────────────────────────────────────────────');
    debugPrint('│ [HTTP] ✓ ${response.statusCode} ${response.requestOptions.path}');
    debugPrint('│ [HTTP] Response: ${response.data}');
    debugPrint('└─────────────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('┌─────────────────────────────────────────────────────');
    debugPrint('│ [HTTP] ✗ ${err.response?.statusCode ?? 'NO_STATUS'} ${err.requestOptions.path}');
    debugPrint('│ [HTTP] Type: ${err.type}');
    debugPrint('│ [HTTP] Message: ${err.message}');
    if (err.response?.data != null) {
      debugPrint('│ [HTTP] Error body: ${err.response?.data}');
    }
    debugPrint('└─────────────────────────────────────────────────────');

    final statusCode = err.response?.statusCode;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      _showErrorSnackbar('Request timed out. Please try again.');
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException('Connection timed out'),
          type: err.type,
        ),
      );
      return;
    }

    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      _showErrorSnackbar('Check your connection and try again.');
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException('No internet connection'),
          type: err.type,
        ),
      );
      return;
    }

    switch (statusCode) {
      case 403:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: const PaywallException(),
            type: DioExceptionType.badResponse,
          ),
        );
        return;

      case 400:
      case 402:
        // Pass through for the calling service to handle
        handler.next(err);
        return;

      case 500:
      case 503:
        _showErrorSnackbar('Something went wrong on our side. Try again.');
        break;

      default:
        break;
    }

    handler.next(err);
  }

  void _showErrorSnackbar(String message) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2A2A32),
      colorText: const Color(0xFFF0EEF4),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      titleText: const SizedBox.shrink(),
    );
  }
}
