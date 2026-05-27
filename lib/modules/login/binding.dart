// lib/modules/login/binding.dart

import 'package:get/get.dart';
import 'controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
