// lib/modules/identity/view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../themes/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/private_id_card.dart';
import 'controller.dart';

export 'controller.dart' show AliasStatus;

class IdentityView extends GetView<IdentityController> {
  const IdentityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // Icon mark
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accentPurple.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                    color: AppColors.accentPurple,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Create your\nprivate identity',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'No name, phone, or email collected.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),

                const SizedBox(height: 40),

                // Alias field
                Text(
                  'Alias',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.aliasController,
                  focusNode: controller.aliasFocusNode,
                  validator: controller.validateAlias,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyMedium,
                  maxLength: 16,
                  decoration: const InputDecoration(
                    hintText: 'choose an alias',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  final status = controller.aliasStatus.value;
                  if (status == AliasStatus.checking) {
                    return Row(
                      children: [
                        const SizedBox(
                          width: 10, height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF8A8A9A)),
                        ),
                        const SizedBox(width: 6),
                        Text('Checking…', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    );
                  }
                  if (status == AliasStatus.available) {
                    return Text('✓ Available', style: AppTextStyles.caption.copyWith(color: Color(0xFF4CAF50)));
                  }
                  if (status == AliasStatus.taken) {
                    return Text('✗ Already taken', style: AppTextStyles.caption.copyWith(color: Color(0xFFE57373)));
                  }
                  return const SizedBox.shrink();
                }),

                const SizedBox(height: 20),

                // PIN field
                Text(
                  '4-digit PIN',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => TextFormField(
                      controller: controller.pinController,
                      validator: controller.validatePin,
                      obscureText: !controller.pinVisible.value,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => controller.enterOpenUp(),
                      maxLength: 4,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: '• • • •',
                        counterText: '',
                        suffixIcon: GestureDetector(
                          onTap: controller.togglePinVisibility,
                          child: Icon(
                            controller.pinVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )),

                const SizedBox(height: 28),

                // Preview ID card
                Obx(() => PrivateIDCard(
                      id: controller.previewId,
                      label: 'Your private session ID',
                      helperText: 'Save this. We cannot recover it.',
                    )),

                const SizedBox(height: 36),

                // CTA
                Obx(() => PrimaryButton(
                      label: 'Enter OpenUp',
                      onPressed: controller.enterOpenUp,
                      isLoading: controller.isLoading.value,
                    )),

                const SizedBox(height: 24),

                // Divider row
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFF2A2A35))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFF2A2A35))),
                  ],
                ),

                const SizedBox(height: 20),

                // Go to login
                Center(
                  child: GestureDetector(
                    onTap: () => Get.offAllNamed(AppRoutes.login),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                        children: [
                          const TextSpan(text: 'Already have an identity? '),
                          TextSpan(
                            text: 'Log in',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accentPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
