// lib/widgets/ghost_button.dart

import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// Full-width outline border button with same dimensions as PrimaryButton.
class GhostButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;

  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.borderColor,
    this.textColor,
  });

  @override
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final borderColor = widget.borderColor ?? AppColors.border;
    final textColor = widget.textColor ?? AppColors.textSecondary;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _controller.reverse() : null,
      onTapUp: isEnabled ? (_) => _controller.forward() : null,
      onTapCancel: isEnabled ? _controller.forward : null,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          height: 52,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
