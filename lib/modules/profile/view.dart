// lib/modules/profile/view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import '../../widgets/access_tier_badge.dart';
import '../../widgets/settings_row.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/text_link_button.dart';
import 'controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.titleMedium),
        backgroundColor: AppColors.bgPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: ShimmerList(itemCount: 5),
          );
        }

        final user = controller.user.value;
        if (user == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SettingsRow(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Subscription & access',
                        onTap: controller.goToSubscription,
                      ),
                    ),
                    const Divider(height: 0, indent: 16, endIndent: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SettingsRow(
                        icon: Icons.shield_outlined,
                        label: 'Privacy settings',
                        onTap: controller.showPrivacyPolicy,
                      ),
                    ),
                    const Divider(height: 0, indent: 16, endIndent: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SettingsRow(
                        icon: Icons.info_outline_rounded,
                        label: 'About & data policy',
                        onTap: controller.showAbout,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Divider
              const Divider(color: AppColors.border, thickness: 0.5),

              const SizedBox(height: 20),

              // Destructive section
              Text(
                'DANGER ZONE',
                style: AppTextStyles.labelSmall.copyWith(
                  letterSpacing: 1.5,
                  color: AppColors.destructive.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Column(
                  children: [
                    DestructiveRow(
                      label: 'Clear all local data',
                      onTap: controller.clearLocalData,
                    ),
                    const Divider(height: 0),
                    DestructiveRow(
                      label: 'Remove this identity',
                      onTap: controller.removeIdentity,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // End session
              Center(
                child: TextLinkButton(
                  label: 'End session',
                  onPressed: controller.endSession,
                  color: AppColors.textSecondary.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 24),
            ],
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: avatar placeholder + tier badge
          Row(
            children: [
              // Avatar circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentPurple.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    user.alias.isNotEmpty
                        ? user.alias[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.accentPurple,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.alias,
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    AccessTierBadge(
                      tier: user.isPremium ? AccessTier.plus : AccessTier.free,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Generated username (if premium)
          if (user.generatedUsername != null &&
              user.generatedUsername!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generated username',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.generatedUsername!,
                          style: AppTextStyles.mono,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Plan info (if premium)
          if (user.isPremium && user.expiryDate != null) ...[
            const SizedBox(height: 12),
            Text(
              'Plan: ${_planLabel(user.planType)} · Expires ${_formatDate(user.expiryDate!)}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  String _planLabel(String? planType) {
    return switch (planType) {
      'daily' => 'Daily',
      'weekly' => 'Weekly',
      'monthly' => 'Monthly',
      _ => 'Free',
    };
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
