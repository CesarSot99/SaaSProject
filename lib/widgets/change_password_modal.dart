import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';

class ChangePasswordModal extends StatefulWidget {
  const ChangePasswordModal({super.key});

  @override
  State<ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<ChangePasswordModal> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onChangePassword() {
    if (!_formKey.currentState!.validate()) return;

    final currentPass = _currentPasswordController.text;
    final newPass = _newPasswordController.text;

    final success = _authService.changePassword(currentPass, newPass);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current password is incorrect or new password is too short.'),
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
                      Icon(Icons.lock_reset_rounded, color: AppTheme.primary, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Change Password',
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

              CustomTextField(
                label: 'Current Password',
                hint: '••••••••',
                controller: _currentPasswordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your current password';
                  return null;
                },
              ),

              const SizedBox(height: 14),

              CustomTextField(
                label: 'New Password',
                hint: 'Minimum 6 characters',
                controller: _newPasswordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value == null || value.length < 6) return 'Minimum 6 characters';
                  return null;
                },
              ),

              const SizedBox(height: 14),

              CustomTextField(
                label: 'Confirm New Password',
                hint: 'Repeat new password',
                controller: _confirmPasswordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value != _newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: 'Update Password',
                icon: Icons.check_circle_outline_rounded,
                onPressed: _onChangePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
