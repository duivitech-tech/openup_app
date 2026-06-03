// lib/modules/profile/view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import '../../widgets/settings_row.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/text_link_button.dart';
import 'controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return SafeArea(
      bottom: false,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: ShimmerList(itemCount: 5),
          );
        }

        final user = controller.user.value;
        if (user == null) return const SizedBox.shrink();

        return RefreshIndicator(
          color: AppColors.accentPurple,
          backgroundColor: AppColors.surface,
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Identity card
                _IdentityCard(controller: controller),

                const SizedBox(height: 28),

                // Settings section
                Text(
                  'SETTINGS',
                  style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.5),
                ),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16),
                        //   child: SettingsRow(
                        //     icon: Icons.workspace_premium_outlined,
                        //     label: 'Subscription & access',
                        //     onTap: controller.goToSubscription,
                        //   ),
                        // ),
                        const Divider(height: 0, indent: 16, endIndent: 16),
                        SettingsRow(
                          icon: Icons.shield_outlined,
                          label: 'Privacy policy',
                          onTap: controller.showPrivacyPolicy,
                        ),
                        const Divider(height: 0, indent: 16, endIndent: 16),
                        SettingsRow(
                          icon: Icons.info_outline_rounded,
                          label: 'About us',
                          onTap: controller.showAbout,
                        ),
                        const Divider(height: 0, indent: 16, endIndent: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Center(
                  child: TextLinkButton(
                    label: 'Log out',
                    onPressed: controller.confirmLogout,
                    color: AppColors.destructive.withValues(alpha: 0.8),
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final ProfileController controller;
  const _IdentityCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final user = controller.user.value;
    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        user.alias,
        style: AppTextStyles.displayLarge.copyWith(
          fontSize: 40,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -1.0,
          height: 1.15,
        ),
      ),
    );
  }
}
