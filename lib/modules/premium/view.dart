// lib/modules/premium/view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import '../../widgets/plan_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/text_link_button.dart';
import 'controller.dart';

class PremiumView extends GetView<PremiumController> {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle (feels like a bottom sheet)
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B7CF6), Color(0xFF4F7EFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.all_inclusive_rounded,
                      color: AppColors.onAccent,
                      size: 24,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "You've reached your daily limit.",
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Free access includes messages per day. Upgrade for unlimited conversations.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Plan cards
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(() => Column(
                      children: PremiumController.plans.map((plan) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PlanCard(
                            planType: plan.type,
                            price: plan.price,
                            period: plan.period,
                            description: plan.description,
                            isMostUsed: plan.isMostUsed,
                            isSelected:
                                controller.selectedPlan.value == plan.type,
                            onTap: () => controller.selectPlan(plan.type),
                          ),
                        );
                      }).toList(),
                    )),
              ),
            ),

            // CTA area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                children: [
                  Obx(() => PrimaryButton(
                        label:
                            'Continue with ${_planLabel(controller.selectedPlan.value)}',
                        onPressed: controller.continueWithPlan,
                        isLoading: controller.isLoading.value,
                      )),
                  const SizedBox(height: 12),
                  Center(
                    child: TextLinkButton(
                      label: 'Not now',
                      onPressed: controller.dismiss,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Cancel anytime · Secure payment via PhonePe',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _planLabel(String planType) {
    return switch (planType) {
      'daily' => 'Daily (₹19)',
      'weekly' => 'Weekly (₹49)',
      'monthly' => 'Monthly (₹199)',
      _ => planType,
    };
  }
}
