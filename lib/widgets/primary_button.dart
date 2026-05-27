// lib/widgets/primary_button.dart
// StatelessWidget — press scale driven by an inline GetxController via Get.put

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../themes/app_theme.dart';

class _ButtonController extends GetxController {
  final isPressed = false.obs;
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDestructive;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Unique tag per instance using label + hashCode
    final tag = 'btn_${label.hashCode}_$hashCode';
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
          if (onPressed != null && !isLoading) onPressed!();
        },
        onTapCancel: () => ctrl.isPressed.value = false,
        child: AnimatedScale(
          scale: isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: width ?? double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: isDestructive
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF8B7CF6), Color(0xFF6B5CE7)],
                    ),
              color: isDestructive ? AppColors.destructive : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isPressed
                  ? null
                  : [
                      BoxShadow(
                        color: (isDestructive
                                ? AppColors.destructive
                                : AppColors.accentPurple)
                            .withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
