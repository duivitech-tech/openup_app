// lib/modules/home/view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/home_dash_card.dart';
import '../../widgets/text_link_button.dart';
import '../profile/view.dart';
import 'controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Obx(() => IndexedStack(
            index: controller.currentNavIndex.value,
            children: const [
              _HomeTab(),
              ProfileView(),
            ],
          )),
      bottomNavigationBar: Obx(() => AppBottomNavBar(
            currentIndex: controller.currentNavIndex.value,
            onTap: controller.onNavTap,
          )),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.accentPurple,
        backgroundColor: AppColors.surface,
        onRefresh: c.refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Obx(() => Text(
                          'hey, ${c.alias.value}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 12),
                  Obx(() => HomeDashCard(
                        isPremium: c.isPremium.value,
                        onStartTalking: c.startChat,
                      )),
                  const SizedBox(height: 20),
                  Obx(() {
                    if (c.isPremium.value) return const SizedBox.shrink();
                    return _UsageStrip();
                  }),
                  const SizedBox(height: 28),
                  _TipsSection(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageStrip extends StatelessWidget {
  const _UsageStrip();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
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
              Text(title,
                  style: AppTextStyles.bodySmall.copyWith(
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
