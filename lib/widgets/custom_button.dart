import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outlined, tertiary }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = AppTheme.primary;
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.secondary:
        backgroundColor = AppTheme.primaryLight;
        foregroundColor = AppTheme.primaryDark;
        borderSide = const BorderSide(color: AppTheme.borderColor);
        break;
      case ButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = AppTheme.primary;
        borderSide = const BorderSide(color: AppTheme.primary, width: 1.5);
        break;
      case ButtonVariant.tertiary:
        backgroundColor = AppTheme.accent;
        foregroundColor = Colors.white;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: Material(
        color: isEnabled ? backgroundColor : backgroundColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: borderSide != BorderSide.none ? Border.fromBorderSide(borderSide) : null,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20, color: foregroundColor),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: foregroundColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
