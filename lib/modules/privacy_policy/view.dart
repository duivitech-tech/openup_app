// lib/modules/privacy_policy/view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/profile/controller.dart';
import '../../themes/app_theme.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Privacy Policy',
          style: AppTextStyles.titleMedium,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Effective date
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 18, color: AppColors.accentPurple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Effective date: June 1, 2025',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _PolicySection(
              title: '1. Overview',
              body:
                  'OpenUp is built on a single foundational promise: your conversations are yours and yours alone. We do not collect, store, transmit, or share any personal data or conversation content. This Privacy Policy describes the minimal technical information that may be accessed to make the app function.',
            ),

            _PolicySection(
              title: '2. Information We Do NOT Collect',
              body:
                  'We do not collect:\n\n• Your name, email address, phone number, or any personally identifiable information.\n• The content of your conversations with the AI.\n• Your location, device contacts, camera, microphone recordings, or photos.\n• Behavioral analytics or usage patterns beyond what is described below.\n• Any data that could be used to identify or profile you.',
            ),

            _PolicySection(
              title: '3. Anonymous Identity (Alias)',
              body:
                  'When you create an account, you are assigned — or you choose — an anonymous alias. This alias is not linked to any real-world identity. It exists solely so you can return to the app across sessions without re-onboarding. We do not ask for, nor do we store, any information that links your alias to a real person.',
            ),

            _PolicySection(
              title: '4. Session-Based Conversations',
              body:
                  'All conversations you have with the AI listener are session-based. This means:\n\n• Conversation content is not written to any database or persistent storage on our servers.\n• When your session ends, your conversation is gone — permanently.\n• No AI model is trained on your conversation data.\n• No human at OpenUp reads your conversations.',
            ),

            _PolicySection(
              title: '5. Device Storage',
              body:
                  'The app may use secure local storage on your device to hold your alias and session token. This data lives only on your device and is never synced to our servers beyond what is necessary for authentication. You can clear this data at any time from the Settings screen.',
            ),

            _PolicySection(
              title: '6. Authentication Tokens',
              body:
                  'To keep you logged in, the app stores an encrypted session token on your device. This token is used to verify your anonymous identity when making API requests. It does not contain or reveal any personal information. Tokens are invalidated when you log out.',
            ),

            _PolicySection(
              title: '7. Third-Party Services',
              body:
                  'OpenUp uses a minimal, privacy-first backend to power the AI conversation layer. We do not integrate with advertising networks, analytics platforms, or social login providers. Any third-party infrastructure used complies with applicable privacy laws and is bound by strict data processing agreements.',
            ),

            _PolicySection(
              title: '8. Children\'s Privacy',
              body:
                  'OpenUp is not intended for users under the age of 13. We do not knowingly collect any data from children. If you believe a child has used the app, please contact us and we will take appropriate steps.',
            ),

            _PolicySection(
              title: '9. Changes to This Policy',
              body:
                  'We may update this Privacy Policy from time to time. When we do, we will update the effective date at the top. Continued use of the app after any changes constitutes your acceptance of the new policy. We encourage you to review this page periodically.',
            ),

            _PolicySection(
              title: '10. Contact',
              body:
                  'If you have any questions or concerns about this Privacy Policy, please contact us at:\n\nsupport@openup.app\n\nWe are committed to responding within 48 hours.',
            ),

            const SizedBox(height: 16),

            // Footer note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentPurple.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Text(
                'TL;DR — We don\'t read your conversations. We don\'t store them. When the session ends, everything disappears. Your privacy is the product.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.accentPurple.withValues(alpha: 0.9),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ── Delete Account ────────────────────────────────────────────
            Divider(color: AppColors.border, thickness: 0.5),
            const SizedBox(height: 24),

            Text(
              'DELETE YOUR ACCOUNT',
              style: AppTextStyles.labelSmall.copyWith(
                letterSpacing: 1.5,
                color: AppColors.destructive.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You have the right to permanently delete your account and all associated data from our systems at any time. This includes your anonymous alias, subscription history, payment records, and authentication tokens.\n\nThis action is irreversible. Once deleted, your account cannot be recovered.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.7,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            Obx(() {
              final controller = Get.find<ProfileController>();
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: controller.isDeleting.value
                      ? null
                      : controller.removeIdentity,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.destructive,
                    side: BorderSide(
                      color: AppColors.destructive.withValues(alpha: 0.6),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isDeleting.value
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.destructive.withValues(alpha: 0.7),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete_forever_rounded,
                                size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Delete My Account',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.destructive,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            }),

            const SizedBox(height: 8),
            Center(
              child: Text(
                'This action cannot be undone.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.destructive.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;

  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.7,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Divider(
            color: AppColors.border,
            thickness: 0.5,
          ),
        ],
      ),
    );
  }
}
