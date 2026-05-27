// lib/repositories/payment_repository.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../core/errors/app_exceptions.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class PaymentRepository extends GetxService {
  late final ApiService _apiService;
  late final StorageService _storage;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[PaymentRepository] onInit');
    _apiService = Get.find<ApiService>();
    _storage = Get.find<StorageService>();
  }

  /// Initiates a PhonePe payment session for the selected plan.
  /// Returns the payment URL to open in a WebView.
  Future<String> initiatePayment(String planType) async {
    debugPrint('[PaymentRepository] initiatePayment: planType=$planType');
    try {
      final accessToken = await _storage.getAuthToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw const UnauthorizedException('You must be logged in to make a payment.');
      }

      final paymentUrl = await _apiService.initiatePayment(accessToken, planType);
      debugPrint('[PaymentRepository] Got paymentUrl: $paymentUrl');
      return paymentUrl;
    } on AppException catch (e) {
      debugPrint('[PaymentRepository] AppException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[PaymentRepository] Unexpected error: $e');
      throw ServerException('Failed to initiate payment: $e');
    }
  }

  /// Polls GET /api/user/profile up to [maxAttempts] times (3s apart).
  /// Returns true when isPremium is confirmed, false on timeout.
  Future<bool> pollForPremium({int maxAttempts = 10}) async {
    debugPrint('[PaymentRepository] pollForPremium started');
    final accessToken = await _storage.getAuthToken();
    if (accessToken == null || accessToken.isEmpty) return false;

    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(seconds: 3));
      try {
        final user = await _apiService.fetchProfile(accessToken);
        debugPrint('[PaymentRepository] poll #${i + 1}: isPremium=${user.isPremium}');
        if (user.isPremium) {
          return true;
        }
      } catch (e) {
        debugPrint('[PaymentRepository] poll #${i + 1} error: $e');
      }
    }
    debugPrint('[PaymentRepository] pollForPremium timed out');
    return false;
  }
}
