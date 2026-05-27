// lib/modules/premium/register_controller.dart

import 'package:get/get.dart';
import '../../repositories/payment_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_snackbar.dart';

class PremiumRegisterController extends GetxController {
  late final PaymentRepository _paymentRepo;

  final showWebView = false.obs;
  final isPolling = false.obs;
  final paymentUrl = ''.obs;
  final planType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _paymentRepo = Get.find<PaymentRepository>();

    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      paymentUrl.value = args['paymentUrl'] as String? ?? '';
      planType.value = args['planType'] as String? ?? 'monthly';
      if (paymentUrl.value.isNotEmpty) showWebView.value = true;
    }
  }

  /// Called when the WebView detects a redirect back to the app.
  Future<void> onPaymentRedirect() async {
    showWebView.value = false;
    isPolling.value = true;

    final confirmed = await _paymentRepo.pollForPremium();

    isPolling.value = false;

    if (confirmed) {
      AppSnackbar.success('Plus access activated!');
      await Future.delayed(const Duration(milliseconds: 600));
      Get.offAllNamed(AppRoutes.home);
    } else {
      AppSnackbar.error(
        'Payment pending — it may take a moment. Check back shortly.',
      );
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void onPaymentFailed() {
    showWebView.value = false;
    AppSnackbar.error('Payment was not completed. Please try again.');
    Get.back();
  }
}
