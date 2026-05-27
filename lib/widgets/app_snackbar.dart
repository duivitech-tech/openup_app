// lib/widgets/app_snackbar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/app_theme.dart';

enum SnackbarType { success, error, info }

/// Static helper for showing styled GetX snackbars.
class AppSnackbar {
  AppSnackbar._();

  static void show({
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    final color = switch (type) {
      SnackbarType.success => AppColors.successDim,
      SnackbarType.error => const Color(0xFF6B1F1F),
      SnackbarType.info => AppColors.surfaceLight,
    };

    final icon = switch (type) {
      SnackbarType.success => Icons.check_circle_outline_rounded,
      SnackbarType.error => Icons.error_outline_rounded,
      SnackbarType.info => Icons.info_outline_rounded,
    };

    final iconColor = switch (type) {
      SnackbarType.success => AppColors.success,
      SnackbarType.error => AppColors.destructive,
      SnackbarType.info => AppColors.accentPurple,
    };

    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: AppColors.textPrimary,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: duration,
      isDismissible: true,
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      borderColor: iconColor.withOpacity(0.3),
      borderWidth: 0.5,
    );
  }

  static void success(String message) =>
      show(message: message, type: SnackbarType.success);

  static void error(String message) =>
      show(message: message, type: SnackbarType.error);

  static void info(String message) =>
      show(message: message, type: SnackbarType.info);
}
