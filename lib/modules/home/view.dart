// lib/modules/home/view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/home_dash_card.dart';
import '../../widgets/text_link_button.dart';
import 'controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar
            _TopBar(),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Main dashboard card
                    Obx(() => HomeDashCard(
                          isPremium: controller.isPremium.value,
                          onStartTalking: controller.startChat,
                        )),

                    const SizedBox(height: 20),

                    // Usage strip (hidden for premium)
                    Obx(() {
                      if (controller.isPremium.value) {
                        return const SizedBox.shrink();
                      }
                      return _UsageStrip();
                    }),

                    const SizedBox(height: 28),

                    // Tips section
                    _TipsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom nav
      bottomNavigationBar: Obx(() => AppBottomNavBar(
            currentIndex: controller.currentNavIndex.value,
            onTap: controller.onNavTap,
          )),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  HomeController get c => Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Obx(() => Text(
                'hey, ${c.alias.value}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              )),
          const Spacer(),
          GestureDetector(
            onTap: c.goToSettings,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: const Icon(
                Icons.settings_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageStrip extends StatelessWidget {
  const _UsageStrip();

  HomeController get c => Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(() => Text(
                  '${c.messagesLeft.value} free messages left today',
                  style: AppTextStyles.bodySmall,
                )),
          ),
          TextLinkButton(
            label: 'Unlock unlimited →',
            onPressed: c.goToPremium,
            color: AppColors.accentPurple,
            fontSize: 12,
          ),
        ],
      ),
    );
  }
}

class _TipsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOW IT WORKS',
          style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.5),
        ),
        const SizedBox(height: 14),
        _TipRow(
          icon: Icons.lock_outline_rounded,
          title: 'Completely private',
          subtitle: 'No account, no tracking, no storage.',
        ),
        const SizedBox(height: 12),
        _TipRow(
          icon: Icons.psychology_outlined,
          title: 'Talk freely',
          subtitle: 'Say what\'s on your mind. We won\'t judge.',
        ),
        const SizedBox(height: 12),
        _TipRow(
          icon: Icons.auto_delete_outlined,
          title: 'Session ends, all clears',
          subtitle: 'When you leave, everything disappears.',
        ),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TipRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: AppColors.accentPurple),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              )),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
