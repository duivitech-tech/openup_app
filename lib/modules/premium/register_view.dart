// lib/modules/premium/register_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';
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
        if (controller.showWebView.value) return const _PaymentWebView();
        if (controller.isPolling.value) return const _PollingView();
        return const SizedBox.shrink();
      }),
    );
  }
}

class _PaymentWebView extends StatelessWidget {
  const _PaymentWebView();

  PremiumRegisterController get c => Get.find<PremiumRegisterController>();

  static const _redirectHost = 'openup-backend.vercel.app';

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
              Text(
                'Secure payment via PhonePe',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
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
              final urlStr = url?.toString() ?? '';
              if (urlStr.contains('success') ||
                  urlStr.contains('redirect') ||
                  urlStr.contains(_redirectHost)) {
                c.onPaymentRedirect();
              } else if (urlStr.contains('fail') ||
                  urlStr.contains('cancel')) {
                c.onPaymentFailed();
              }
            },
            onReceivedError: (wc, req, err) => c.onPaymentFailed(),
          ),
        ),
      ],
    );
  }
}

class _PollingView extends StatelessWidget {
  const _PollingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.accentPurple,
            strokeWidth: 2,
          ),
          const SizedBox(height: 20),
          Text(
            'Confirming your payment…',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'This usually takes a few seconds.',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
