// lib/widgets/access_tier_badge.dart

import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

enum AccessTier { free, plus }

/// Free / Plus badge pill.
class AccessTierBadge extends StatelessWidget {
  final AccessTier tier;

  const AccessTierBadge({super.key, required this.tier});

  @override
  Widget build(BuildContext context) {
    final isPlus = tier == AccessTier.plus;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        gradient: isPlus
            ? const LinearGradient(
                colors: [Color(0xFF8B7CF6), Color(0xFF4F7EFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPlus ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: isPlus
            ? null
            : Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Text(
        isPlus ? 'Plus' : 'Free',
        style: AppTextStyles.labelSmall.copyWith(
          color: isPlus ? AppColors.onAccent : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
