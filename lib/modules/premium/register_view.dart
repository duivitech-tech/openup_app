// lib/modules/premium/register_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
import '../../widgets/primary_button.dart';
import 'register_controller.dart';

class PremiumRegisterView extends GetView<PremiumRegisterController> {
  const PremiumRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Plus access'),
        backgroundColor: AppColors.bgPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.showWebView.value) {
          return const _PaymentWebView();
        }
        return const _RegistrationForm();
      }),
    );
  }
}

/// WebView that opens PhonePe payment URL.
class _PaymentWebView extends StatelessWidget {
  const _PaymentWebView();

  PremiumRegisterController get c => Get.find<PremiumRegisterController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.bgSecondary,
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 14, color: AppColors.success),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Secure payment via PhonePe',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(c.paymentUrl.value),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              thirdPartyCookiesEnabled: true,
            ),
            onLoadStop: (wc, url) {
              // Detect payment success/failure by URL patterns
              final urlStr = url?.toString() ?? '';
              if (urlStr.contains('success') ||
                  urlStr.contains('redirect') ||
                  urlStr.contains('openup-backend.vercel.app')) {
                c.onPaymentComplete();
              } else if (urlStr.contains('fail') ||
                  urlStr.contains('cancel')) {
                c.onPaymentFailed();
              }
            },
            onReceivedError: (wc, req, err) {
              c.onPaymentFailed();
            },
          ),
        ),
      ],
    );
  }
}

/// Registration form after payment is completed.
class _RegistrationForm extends StatelessWidget {
  const _RegistrationForm();

  PremiumRegisterController get c => Get.find<PremiumRegisterController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: c.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Payment success indicator (if payment was completed)
              Obx(() {
                if (!c.paymentCompleted.value) {
                  return const SizedBox.shrink();
                }
                return Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.successDim.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          color: AppColors.success, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Payment successful!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              Text(
                'Set up your\nPlus access',
                style: AppTextStyles.displayLarge.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Your account is tied to this device and PIN only.',
                style: AppTextStyles.bodySmall,
              ),

              const SizedBox(height: 32),

              // Plan display pill
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.all_inclusive_rounded,
                          size: 14,
                          color: AppColors.accentPurple,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _planLabel(c.planType.value),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.accentPurple,
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 28),

              // Nickname field
              Text(
                'Nickname',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: c.nicknameController,
                validator: c.validateNickname,
                textInputAction: TextInputAction.next,
                style: AppTextStyles.bodyMedium,
                maxLength: 16,
                decoration: const InputDecoration(
                  hintText: 'choose a nickname',
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
                    controller: c.pinController,
                    validator: c.validatePin,
                    obscureText: !c.pinVisible.value,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    maxLength: 4,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: '• • • •',
                      counterText: '',
                      suffixIcon: GestureDetector(
                        onTap: c.togglePinVisibility,
                        child: Icon(
                          c.pinVisible.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )),

              const SizedBox(height: 36),

              // CTA
              Obx(() => PrimaryButton(
                    label: 'Activate my access',
                    onPressed: c.activateAccess,
                    isLoading: c.isLoading.value,
                  )),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  'Your PIN is the only way to access your account.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _planLabel(String planType) {
    return switch (planType) {
      'daily' => 'Daily Plan · ₹19',
      'weekly' => 'Weekly Plan · ₹49',
      'monthly' => 'Monthly Plan · ₹199',
      _ => 'Plus Plan',
    };
  }
}
