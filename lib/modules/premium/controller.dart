// lib/modules/premium/controller.dart

import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';
import '../../repositories/device_repository.dart';
import '../../repositories/payment_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_snackbar.dart';

class PremiumController extends GetxController {
  late final DeviceRepository _deviceRepo;
  late final PaymentRepository _paymentRepo;

  final selectedPlan = AppConstants.planMonthly.obs;
  final isLoading = false.obs;

  static const plans = [
    _PlanData(
      type: AppConstants.planDaily,
      price: '₹19',
      period: '/day',
      description: 'Basic access',
      isMostUsed: false,
    ),
    _PlanData(
      type: AppConstants.planWeekly,
      price: '₹49',
      period: '/week',
      description: 'Unlimited sessions',
      isMostUsed: false,
    ),
    _PlanData(
      type: AppConstants.planMonthly,
      price: '₹199',
      period: '/month',
      description: 'Best value',
      isMostUsed: true,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _deviceRepo = Get.find<DeviceRepository>();
    _paymentRepo = Get.find<PaymentRepository>();
  }

  void selectPlan(String planType) {
    selectedPlan.value = planType;
  }

  Future<void> continueWithPlan() async {
    isLoading.value = true;
    try {
      final deviceId = await _deviceRepo.getDeviceId();
      final paymentUrl =
          await _paymentRepo.initiatePayment(deviceId, selectedPlan.value);

      // Navigate to premium register screen with payment URL
      Get.toNamed(
        AppRoutes.premiumRegister,
        arguments: {
          'paymentUrl': paymentUrl,
          'planType': selectedPlan.value,
        },
      );
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Payment initiation failed. Try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void dismiss() => Get.back();
}

class _PlanData {
  final String type;
  final String price;
  final String period;
  final String description;
  final bool isMostUsed;

  const _PlanData({
    required this.type,
    required this.price,
    required this.period,
    required this.description,
    required this.isMostUsed,
  });
}
