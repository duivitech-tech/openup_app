// lib/modules/about_us/view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_theme.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

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
          'About Us',
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
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPurple.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.accentPurple.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'OpenUp',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Version 1.0.0',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '"Someone\'s listening."',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.accentPurple.withValues(alpha: 0.85),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _AboutSection(
              icon: Icons.lightbulb_outline_rounded,
              title: 'The Idea',
              body:
                  'OpenUp was born out of a simple, uncomfortable truth: most people have things they need to say, but no safe place to say them.\n\nNot every feeling deserves a therapy session. Not every thought can be shared with a friend. Not every burden should be carried alone. And yet — people are. Quietly. Every day.',
            ),

            _AboutSection(
              icon: Icons.psychology_outlined,
              title: 'Why We Built This',
              body:
                  'We saw a gap. The world is full of wellness apps that track your mood, store your journal, send you push notifications, and quietly build a data profile on your emotional life. We found that unsettling.\n\nWhat if you could just... talk? To something that listens without judgment, without memory, without an agenda. No stored transcripts. No AI training on your words. No record that it ever happened.\n\nThat\'s what OpenUp is. A private, session-based space where you speak freely — and when you\'re done, the conversation disappears completely.',
            ),

            _AboutSection(
              icon: Icons.lock_outline_rounded,
              title: 'Privacy as a Core Value',
              body:
                  'Privacy isn\'t a feature at OpenUp — it\'s the foundation.\n\nWe deliberately chose not to build a system that learns from you over time, stores your sessions, or monetises your emotional data. Every design decision has been made with one question in mind: would we be comfortable if our own conversations were handled this way?\n\nThe answer had to be yes before we shipped anything.',
            ),

            _AboutSection(
              icon: Icons.people_outline_rounded,
              title: 'Who It\'s For',
              body:
                  'OpenUp is for anyone who\'s ever thought:\n\n• "I just need to get this out of my head."\n• "I don\'t want to burden the people around me."\n• "I need to think out loud, but I don\'t know who to talk to."\n• "I\'m not ready for therapy — but I need something."\n\nYou don\'t need a diagnosis. You don\'t need a crisis. You just need a moment to be heard.',
            ),

            _AboutSection(
              icon: Icons.auto_awesome_outlined,
              title: 'The AI Listener',
              body:
                  'The AI at the heart of OpenUp is designed to be a listener first. It asks follow-up questions, reflects what it hears, and holds space for you to process — without rushing to fix, advise, or diagnose.\n\nIt is not a replacement for professional mental health support. If you are in crisis, please reach out to a qualified professional or emergency services. OpenUp is a supplement — a quiet, always-available space for everyday emotional processing.',
            ),

            _AboutSection(
              icon: Icons.rocket_launch_outlined,
              title: 'What\'s Next',
              body:
                  'We\'re a small, thoughtful team building something we believe the world needs. OpenUp is just the beginning. We\'re exploring features like guided reflection prompts, topic-based sessions, and optional voice conversations — always with privacy at the core.\n\nThank you for being here. We hope OpenUp gives you even a moment of relief.',
              isLast: true,
            ),

            const SizedBox(height: 8),

            // Team note
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Made with care',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accentPurple,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'OpenUp is built by a team that genuinely believes in the power of being heard. Every line of code, every design decision, every word in this app was made with you — the person who needed somewhere to turn — in mind.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool isLast;

  const _AboutSection({
    required this.icon,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 17, color: AppColors.accentPurple),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.7,
              fontSize: 14,
            ),
          ),
          if (!isLast) ...[
            const SizedBox(height: 8),
            const Divider(color: AppColors.border, thickness: 0.5),
          ],
        ],
      ),
    );
  }
}
