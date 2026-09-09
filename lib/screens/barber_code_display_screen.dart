import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'barber/barber_main_shell.dart';

class BarberCodeDisplayScreen extends StatelessWidget {
  final BarberUser barber;

  const BarberCodeDisplayScreen({
    super.key,
    required this.barber,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: barber.phone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Text('Phone number ${barber.phone} copied to clipboard!'),
          ],
        ),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareCode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: Connect with me on the app using my phone number "${barber.phone}"!'),
        backgroundColor: AppTheme.tertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proTitle = barber.businessType.professionalTitle;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(),

              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.success, width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppTheme.success,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '$proTitle Account Activated!',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome, ${barber.fullName}. Your account and subscription are active.',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Phone Number Display Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'YOUR CLIENT LINK PHONE NUMBER',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      barber.phone,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Share your phone number with your clients so they can register linked directly to you.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Copy & Share buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _copyToClipboard(context),
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: const Text('Copy Phone'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: const BorderSide(color: AppTheme.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _shareCode(context),
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: const Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.tertiary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              CustomButton(
                text: 'Go to Dashboard',
                icon: Icons.dashboard_rounded,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BarberMainShell(),
                    ),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
