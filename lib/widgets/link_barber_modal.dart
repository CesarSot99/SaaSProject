import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';

class LinkBarberModal extends StatefulWidget {
  const LinkBarberModal({super.key});

  @override
  State<LinkBarberModal> createState() => _LinkBarberModalState();
}

class _LinkBarberModalState extends State<LinkBarberModal> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onLinkBarber() {
    if (!_formKey.currentState!.validate()) return;

    final input = _codeController.text.trim();
    final success = _authService.linkBarberToCustomer(input);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favorite barber linked successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No barbershop found with that code or phone number. Please check and try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.storefront_rounded, color: AppTheme.primary, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Link Favorite Barber',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const Divider(color: AppTheme.borderColor, height: 24),

              const Text(
                'Enter the unique barber code provided by your barber or their registered phone number to connect your account directly with their booking schedule.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Barber Code or Phone',
                hint: 'e.g. BARB-7X92K or +1 (555) 987-6543',
                controller: _codeController,
                prefixIcon: Icons.qr_code_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter code or phone';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demo Code: +1 (555) 987-6543 or BARB-7X92K (Carlos Rodriguez - Elite Barber Shop)',
                        style: TextStyle(color: AppTheme.primary, fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: 'Link Barber',
                icon: Icons.link_rounded,
                onPressed: _onLinkBarber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
