// lib/widgets/app_update_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_update_model.dart';
import '../themes/app_theme.dart';

/// Shows the app-update dialog.
///
/// If [update.forceUpdate] is true the dialog is NOT dismissible —
/// the back button and barrier tap are both disabled.
/// Otherwise the user can dismiss it with the "Later" button or
/// by tapping outside.
Future<void> showAppUpdateDialog(AppUpdateModel update) async {
  final isForce = update.forceUpdate;

  await Get.dialog(
    PopScope(
      // Block hardware back on force-update
      canPop: !isForce,
      child: _AppUpdateDialog(update: update, isForce: isForce),
    ),
    barrierDismissible: !isForce,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    useSafeArea: true,
  );
}

class _AppUpdateDialog extends StatelessWidget {
  final AppUpdateModel update;
  final bool isForce;

  const _AppUpdateDialog({required this.update, required this.isForce});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      // Flutter's dialog route injects an underline decoration by default.
      // Reset it here so no text inside the dialog inherits it.
      style: const TextStyle(decoration: TextDecoration.none),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Gradient banner ──────────────────────────────────────────
                _UpdateBanner(isForce: isForce),

                // ── Body ─────────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isForce ? 'Update Required' : 'Update Available',
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isForce
                            ? 'You must update to continue using the app.'
                            : 'A new version is available with improvements.',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 16),

                      // ── Version row ──────────────────────────────────────
                      _VersionRow(
                        currentVersion: update.currentVersion,
                        latestVersion: update.latestVersion ?? update.currentVersion,
                      ),

                      // ── Release notes ────────────────────────────────────
                      if (update.releaseNotes != null &&
                          update.releaseNotes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          "What's new",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          update.releaseNotes!,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Update button ─────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentPurple,
                            foregroundColor: AppColors.onAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => _openStore(update.downloadUrl),
                          child: Text(
                            'Update Now',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // ── "Later" button — hidden on force update ───────────
                      if (!isForce) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Get.back(),
                            child: Text(
                              'Maybe Later',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(String? url) async {
    final target = url ?? 'https://play.google.com/store/';
    final uri = Uri.tryParse(target);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Gradient banner shown at the top of the dialog.
class _UpdateBanner extends StatelessWidget {
  final bool isForce;
  const _UpdateBanner({required this.isForce});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isForce
              ? [
                  const Color(0xFF6A3DE8),
                  const Color(0xFF4F7EFF),
                ]
              : [
                  const Color(0xFF8B7CF6),
                  const Color(0xFF6A3DE8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background circles for depth
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Icon + title
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isForce
                        ? Icons.system_update_rounded
                        : Icons.new_releases_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isForce ? 'Update Required' : 'New Update',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows current → latest version pill row.
class _VersionRow extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;

  const _VersionRow({
    required this.currentVersion,
    required this.latestVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          _VersionBadge(label: 'Current', version: currentVersion, isOld: true),
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward_rounded,
                    size: 14, color: AppColors.textSecondary),
              ],
            ),
          ),
          _VersionBadge(
              label: 'Latest', version: latestVersion, isOld: false),
        ],
      ),
    );
  }
}

class _VersionBadge extends StatelessWidget {
  final String label;
  final String version;
  final bool isOld;

  const _VersionBadge({
    required this.label,
    required this.version,
    required this.isOld,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isOld ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall,
        ),
        const SizedBox(height: 2),
        Text(
          'v$version',
          style: AppTextStyles.bodySmall.copyWith(
            color: isOld
                ? AppColors.textSecondary
                : AppColors.accentPurple,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
