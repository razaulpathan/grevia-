import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Grevia'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.forum_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Grevia',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Version 1.0.0 (Production Build)',
                style: TextStyle(color: AppColors.iconMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Text(
                'Grevia is an advanced realtime social messaging application built with Flutter, Riverpod Clean Architecture, Firebase Cloud Services, and WebRTC peer-to-peer media streaming.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary,
                ),
              ),
              const Spacer(),
              const Text(
                '© 2026 Grevia Inc. All rights reserved.',
                style: TextStyle(color: AppColors.iconMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
