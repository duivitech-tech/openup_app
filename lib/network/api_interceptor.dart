// lib/network/api_interceptor.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../core/errors/app_exceptions.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API ERROR] ${err.response?.statusCode} ${err.requestOptions.path}');

    final statusCode = err.response?.statusCode;

    // Network/timeout errors
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

    // HTTP error codes
    switch (statusCode) {
      case 403:
        // Let the calling service handle — reject with typed error
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
        // Bad request / payment required — pass through for controllers to handle
        handler.next(err);
        return;

      case 500:
      case 503:
        _showErrorSnackbar('Something went wrong. Try again later.');
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
