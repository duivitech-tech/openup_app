// lib/widgets/typing_indicator.dart

import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// Animated 3-dot typing indicator in AI bubble style.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  static const int _dotCount = 3;
  static const int _staggerMs = 200;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      _dotCount,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    // Start each dot with a stagger delay
    for (int i = 0; i < _dotCount; i++) {
      Future.delayed(Duration(milliseconds: i * _staggerMs), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

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
              color: AppColors.accentPurple.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentPurple.withOpacity(0.4),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(
                color: AppColors.border.withOpacity(0.5),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_dotCount, (i) {
                return FadeTransition(
                  opacity: _animations[i],
                  child: Container(
                    width: 6,
                    height: 6,
                    margin: EdgeInsets.only(right: i < _dotCount - 1 ? 4 : 0),
                    decoration: const BoxDecoration(
                      color: AppColors.accentPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
