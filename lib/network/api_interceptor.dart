// lib/network/api_interceptor.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../core/constants/api_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../routes/app_routes.dart';
import '../services/storage_service.dart';

class ApiInterceptor extends Interceptor {
  // Prevents multiple simultaneous refresh calls
  bool _isRefreshing = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('┌─────────────────────────────────────────────────────');
    debugPrint('│ [HTTP] ➤ ${options.method} ${options.uri}');
    if (options.data != null) debugPrint('│ [HTTP] Body: ${options.data}');
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
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('┌─────────────────────────────────────────────────────');
    debugPrint('│ [HTTP] ✗ ${err.response?.statusCode ?? 'NO_STATUS'} ${err.requestOptions.path}');
    debugPrint('│ [HTTP] Type: ${err.type}');
    debugPrint('│ [HTTP] Message: ${err.message}');
    if (err.response?.data != null) {
      debugPrint('│ [HTTP] Error body: ${err.response?.data}');
    }
    debugPrint('└─────────────────────────────────────────────────────');

    // ── Timeout / connectivity ────────────────────────────────────────────────
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      _showErrorSnackbar('Request timed out. Please try again.');
      return handler.reject(DioException(
        requestOptions: err.requestOptions,
        error: const NetworkException('Connection timed out'),
        type: err.type,
      ));
    }

    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      _showErrorSnackbar('Check your connection and try again.');
      return handler.reject(DioException(
        requestOptions: err.requestOptions,
        error: const NetworkException('No internet connection'),
        type: err.type,
      ));
    }

    final statusCode = err.response?.statusCode;

    // ── 401 — try token refresh, then retry original request ─────────────────
    if (statusCode == 401) {
      // Don't refresh on the refresh/login/signup endpoints themselves
      final path = err.requestOptions.path;
      final isAuthEndpoint = path == ApiConstants.authRefresh ||
          path == ApiConstants.authLogin ||
          path == ApiConstants.authSignup;

      if (!isAuthEndpoint && !_isRefreshing) {
        _isRefreshing = true;

        // ── Step 1: refresh the token (isolated try-catch) ──────────────────
        String? newAccessToken;
        try {
          newAccessToken = await _refreshToken();
        } catch (e) {
          debugPrint('[Interceptor] _refreshToken error: $e');
        } finally {
          _isRefreshing = false;
        }

        // ── Step 2: if we got a new token, retry the original request ────────
        if (newAccessToken != null) {
          debugPrint('[Interceptor] Retrying request with new accessToken');
          try {
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';
            final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
            final retryResponse = await dio.fetch(opts);
            return handler.resolve(retryResponse);
          } on DioException catch (retryErr) {
            // The retry itself failed (e.g. 403 daily limit, 400, etc.).
            // This is NOT a refresh failure — propagate it through the normal
            // error-handling switch below so PaywallException / etc. fire correctly.
            debugPrint('[Interceptor] Retry request failed (${retryErr.response?.statusCode}): forwarding error');
            return handler.next(retryErr);
          } catch (retryErr) {
            debugPrint('[Interceptor] Retry request unexpected error: $retryErr');
            return handler.next(DioException(
              requestOptions: err.requestOptions,
              error: retryErr,
              type: DioExceptionType.unknown,
            ));
          }
        }

        // ── Step 3: refresh failed — force logout ────────────────────────────
        debugPrint('[Interceptor] Session expired — forcing logout');
        await _forceLogout();
        return handler.reject(DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          error: const SessionExpiredException(),
          type: DioExceptionType.badResponse,
        ));
      }
    }

    // ── Other status codes ────────────────────────────────────────────────────
    switch (statusCode) {
      case 403:
        return handler.reject(DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          error: const PaywallException(),
          type: DioExceptionType.badResponse,
        ));
      case 500:
      case 503:
        _showErrorSnackbar('Something went wrong on our side. Try again.');
        break;
      default:
        break;
    }

    handler.next(err);
  }

  /// Calls POST /api/auth/refresh and stores the new accessToken.
  /// Returns the new token on success, null on failure.
  Future<String?> _refreshToken() async {
    debugPrint('[Interceptor] Attempting token refresh');
    try {
      final storage = Get.find<StorageService>();
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('[Interceptor] No refreshToken in storage');
        return null;
      }

      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await dio.post(
        ApiConstants.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = (response.data as Map<String, dynamic>)['accessToken'] as String?;
      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await storage.setAuthToken(newAccessToken);
        debugPrint('[Interceptor] New accessToken stored');
        return newAccessToken;
      }
      return null;
    } catch (e) {
      debugPrint('[Interceptor] _refreshToken error: $e');
      return null;
    }
  }

  /// Clears all tokens and navigates to login.
  Future<void> _forceLogout() async {
    try {
      final storage = Get.find<StorageService>();
      await storage.deleteAuthToken();
      await storage.deleteRefreshToken();
      await storage.deleteUserId();
      await storage.clearUserData();
    } catch (e) {
      debugPrint('[Interceptor] _forceLogout storage error: $e');
    }
    if (Get.currentRoute != AppRoutes.login) {
      Get.offAllNamed(AppRoutes.login);
    }
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
