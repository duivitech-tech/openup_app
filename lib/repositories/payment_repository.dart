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
  Future<String> initiatePayment(String deviceId, String planType) async {
    debugPrint('[PaymentRepository] initiatePayment: deviceId=$deviceId, planType=$planType');
    try {
      await _storage.setPlanType(planType);
      debugPrint('[PaymentRepository] Saved planType=$planType to storage');

      final paymentUrl = await _apiService.initiatePayment(deviceId, planType);
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

  /// Retrieves the last selected plan type from storage.
  Future<String?> getSelectedPlan() async {
    final plan = await _storage.getPlanType();
    debugPrint('[PaymentRepository] getSelectedPlan: $plan');
    return plan;
  }
}
