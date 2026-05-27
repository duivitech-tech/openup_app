// lib/repositories/payment_repository.dart

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
    _apiService = Get.find<ApiService>();
    _storage = Get.find<StorageService>();
  }

  /// Initiates a PhonePe payment session for the selected plan.
  /// Returns the payment URL to open in a WebView.
  Future<String> initiatePayment(String deviceId, String planType) async {
    try {
      // Persist the selected plan type so it survives the payment WebView flow
      await _storage.setPlanType(planType);

      final paymentUrl = await _apiService.initiatePayment(deviceId, planType);
      return paymentUrl;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to initiate payment: $e');
    }
  }

  /// Retrieves the last selected plan type from storage.
  Future<String?> getSelectedPlan() => _storage.getPlanType();
}
