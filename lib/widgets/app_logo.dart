import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool showSubtitle;

  const AppLogo({
    super.key,
    this.iconSize = 48.0,
    this.fontSize = 28.0,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize * 1.6,
          height: iconSize * 1.6,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                AppTheme.primary,
                AppTheme.accent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppTheme.primaryLight,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surface,
            ),
            child: Icon(
              Icons.content_cut_rounded,
              size: iconSize * 0.8,
              color: AppTheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            children: const [
              TextSpan(
                text: 'Barber',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              TextSpan(
                text: 'Sync',
                style: TextStyle(color: AppTheme.primary),
              ),
            ],
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 4),
          const Text(
            'BARBER MANAGEMENT & APPOINTMENTS',
            style: TextStyle(
              color: AppTheme.accent,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ],
    );
  }
}
