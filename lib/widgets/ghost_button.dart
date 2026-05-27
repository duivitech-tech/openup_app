// lib/widgets/ghost_button.dart
// StatelessWidget — press scale driven by an inline GetxController

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../themes/app_theme.dart';

class _ButtonController extends GetxController {
  final isPressed = false.obs;
}

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? width;
  final Color? borderColor;
  final Color? textColor;

  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.width,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final tag = 'ghost_${label.hashCode}_$hashCode';
    final ctrl = Get.put(_ButtonController(), tag: tag);

    return Obx(() {
      final isPressed = ctrl.isPressed.value;
      return GestureDetector(
        onTapDown: (_) {
          ctrl.isPressed.value = true;
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) {
          ctrl.isPressed.value = false;
          onPressed?.call();
        },
        onTapCancel: () => ctrl.isPressed.value = false,
        child: AnimatedScale(
          scale: isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: width ?? double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: isPressed
                  ? (borderColor ?? AppColors.accentPurple).withValues(alpha: 0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor ?? AppColors.border,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: textColor ?? AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
