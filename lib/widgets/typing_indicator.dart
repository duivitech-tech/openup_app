// lib/widgets/typing_indicator.dart
// Pure StatelessWidget — 3-dot bounce animation via staggered TweenAnimationBuilder

import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // AI avatar
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, bottom: 2),
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentPurple.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 14,
              color: AppColors.accentPurple,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulseDot(delayMs: 0),
                const SizedBox(width: 4),
                _PulseDot(delayMs: 200),
                const SizedBox(width: 4),
                _PulseDot(delayMs: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Single pulsing dot using TweenAnimationBuilder — no AnimationController needed.
class _PulseDot extends StatelessWidget {
  final int delayMs;

  const _PulseDot({required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeInOut,
      builder: (_, value, __) {
        // Oscillate opacity: 0.3 → 1.0 → 0.3
        final opacity = 0.3 + (0.7 * (value <= 0.5 ? value * 2 : (1 - value) * 2));
        return Opacity(
          opacity: opacity.clamp(0.3, 1.0),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.accentPurple,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
