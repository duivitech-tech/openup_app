// lib/modules/splash/view.dart
// Fully StatelessWidget — animation driven by controller.opacity (Obx)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import 'controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: Obx(() => AnimatedOpacity(
              opacity: controller.opacity.value,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App wordmark
                  Text(
                    'OpenUp',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  Text(
                    "Someone's listening.",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Subtle loader
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.2,
                      color: AppColors.accentPurple.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
