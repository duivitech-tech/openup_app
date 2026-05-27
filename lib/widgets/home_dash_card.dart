// lib/widgets/home_dash_card.dart

import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import 'primary_button.dart';
import 'access_tier_badge.dart';

/// Main home screen dashboard card with CTA.
class HomeDashCard extends StatelessWidget {
  final bool isPremium;
  final VoidCallback onStartTalking;

  const HomeDashCard({
    super.key,
    required this.isPremium,
    required this.onStartTalking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: label + badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI LISTENER',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              if (isPremium)
                const AccessTierBadge(tier: AccessTier.plus)
              else
                // Status: Ready
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Ready',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Decorative icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.accentPurple.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.accentPurple,
              size: 26,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "Someone's\nlistening.",
            style: AppTextStyles.displayLarge.copyWith(
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Private session · nothing saved',
            style: AppTextStyles.bodySmall,
          ),

          const SizedBox(height: 24),

          PrimaryButton(
            label: 'Start talking',
            onPressed: onStartTalking,
          ),
        ],
      ),
    );
  }
}
