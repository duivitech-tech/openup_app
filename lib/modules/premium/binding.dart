// lib/modules/premium/binding.dart

import 'package:get/get.dart';
import 'controller.dart';

class PremiumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PremiumController>(() => PremiumController());
  }
}
