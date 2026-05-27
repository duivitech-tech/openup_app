// lib/modules/onboarding/controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  static const int totalPages = 3;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      goToIdentity();
    }
  }

  void skip() => goToIdentity();

  void goToIdentity() {
    Get.offAllNamed(AppRoutes.identity);
  }

  bool get isLastPage => currentPage.value == totalPages - 1;
}
