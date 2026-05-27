// lib/modules/onboarding/view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import '../../widgets/ghost_button.dart';
import '../../widgets/dot_page_indicator.dart';
import '../../widgets/text_link_button.dart';
import 'controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button top-right
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 20),
                child: TextLinkButton(
                  label: 'Skip',
                  onPressed: controller.skip,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: const [
                  _OnboardingSlide(
                    headline: 'No account required.',
                    subtext: 'Your alias is all you need.',
                    icon: Icons.shield_outlined,
                  ),
                  _OnboardingSlide(
                    headline: 'Nothing is saved.',
                    subtext: 'Sessions clear the moment you leave.',
                    icon: Icons.auto_delete_outlined,
                  ),
                  _OnboardingSlide(
                    headline: "Someone's listening.",
                    subtext: 'Talk freely. No pressure.',
                    icon: Icons.favorite_border_rounded,
                  ),
                ],
              ),
            ),

            // Dot indicator
            Obx(() => DotPageIndicator(
                  count: OnboardingController.totalPages,
                  current: controller.currentPage.value,
                )),

            const SizedBox(height: 32),

            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Obx(() => GhostButton(
                    label: controller.isLastPage ? 'Get started' : 'Continue',
                    onPressed: controller.nextPage,
                    borderColor: AppColors.accentPurple.withValues(alpha: 0.6),
                    textColor: AppColors.accentPurple,
                  )),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final String headline;
  final String subtext;
  final IconData icon;

  const _OnboardingSlide({
    required this.headline,
    required this.subtext,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accentPurple.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(icon, size: 36, color: AppColors.accentPurple),
          ),

          const SizedBox(height: 36),

          Text(
            headline,
            textAlign: TextAlign.center,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            subtext,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
