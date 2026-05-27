// lib/widgets/plan_card.dart

import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// Selectable plan card for the premium paywall.
class PlanCard extends StatelessWidget {
  final String planType; // daily | weekly | monthly
  final String price;
  final String period;
  final String description;
  final bool isSelected;
  final bool isMostUsed;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.planType,
    required this.price,
    required this.period,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.isMostUsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentPurple.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentPurple : AppColors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.accentPurple : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentPurple
                      : AppColors.textSecondary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: AppColors.onAccent)
                  : null,
            ),

            const SizedBox(width: 14),

            // Plan details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _capitalize(planType),
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isMostUsed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF8B7CF6),
                                Color(0xFF4F7EFF),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Most used',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.onAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isSelected
                        ? AppColors.accentPurple
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  period,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
