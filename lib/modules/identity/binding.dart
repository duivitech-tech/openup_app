// lib/modules/identity/binding.dart

import 'package:get/get.dart';
import 'controller.dart';

class IdentityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IdentityController>(() => IdentityController());
  }
}
