// lib/widgets/text_link_button.dart

import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// Inline text link button — no underline, muted color, minimal tap target.
class TextLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final double? fontSize;

  const TextLinkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: color ?? AppColors.accentPurple,
            fontSize: fontSize,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
