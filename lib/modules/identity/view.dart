// lib/modules/identity/view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/private_id_card.dart';
import 'controller.dart';

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
                    color: AppColors.textSecondary.withOpacity(0.8),
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
                  validator: controller.validateAlias,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyMedium,
                  maxLength: 16,
                  decoration: const InputDecoration(
                    hintText: 'choose an alias',
                    counterText: '',
                  ),
                ),

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

                const SizedBox(height: 16),

                Center(
                  child: Text(
                    'No name, phone, or email collected.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
