// lib/widgets/dot_page_indicator.dart

import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// Animated dot page progress indicator for onboarding.
class DotPageIndicator extends StatelessWidget {
  final int count;
  final int current;

  const DotPageIndicator({
    super.key,
    required this.count,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.accentPurple
                : AppColors.textSecondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
