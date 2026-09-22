import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CinemaLogo extends StatelessWidget {
  const CinemaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top cinematic lines
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 2, color: AppTheme.background),
              const SizedBox(width: 8),
              Container(width: 8, height: 2, color: AppTheme.primary),
              const SizedBox(width: 8),
              Container(width: 40, height: 2, color: AppTheme.background),
            ],
          ),
          const SizedBox(height: 16),
          // Main text
          const Text(
            'STARPLEX',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
              letterSpacing: 8.0,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Subtext
          const Text(
            'PREMIUM EXPERIENCE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.background,
              letterSpacing: 4.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Bottom cinematic lines
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 2, color: AppTheme.background),
              const SizedBox(width: 8),
              Container(width: 8, height: 2, color: AppTheme.primary),
              const SizedBox(width: 8),
              Container(width: 40, height: 2, color: AppTheme.background),
            ],
          ),
        ],
      ),
    );
  }
}
