// lib/modules/onboarding/binding.dart

import 'package:get/get.dart';
import 'controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
