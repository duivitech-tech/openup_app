// lib/modules/premium/register_binding.dart

import 'package:get/get.dart';
import 'register_controller.dart';

class PremiumRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PremiumRegisterController>(() => PremiumRegisterController());
  }
}
