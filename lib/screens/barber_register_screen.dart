import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'plan_selection_screen.dart';

class BarberRegisterScreen extends StatefulWidget {
  final String? initialProfession;

  const BarberRegisterScreen({
    super.key,
    this.initialProfession,
  });

  @override
  State<BarberRegisterScreen> createState() => _BarberRegisterScreenState();
}

class _BarberRegisterScreenState extends State<BarberRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopLocationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  BusinessType _selectedBusinessType = BusinessType.barberShop;

  @override
  void initState() {
    super.initState();
    if (widget.initialProfession != null) {
      final prof = widget.initialProfession!;
      if (prof.contains('Hair & Beauty')) {
        _selectedBusinessType = BusinessType.hairSalon;
      } else if (prof.contains('Nail')) {
        _selectedBusinessType = BusinessType.nailStudio;
      } else if (prof.contains('Lash')) {
        _selectedBusinessType = BusinessType.lashAndBrow;
      } else if (prof.contains('Esthetician')) {
        _selectedBusinessType = BusinessType.esthetician;
      } else {
        _selectedBusinessType = BusinessType.barberShop;
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _shopNameController.dispose();
    _shopLocationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlanSelectionScreen(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            shopName: _shopNameController.text.trim(),
            shopLocation: _shopLocationController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            businessType: _selectedBusinessType,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_pin_rounded, size: 16, color: AppTheme.primary),
                      SizedBox(width: 6),
                      Text(
                        'Step 1 of 3: Personal & Shop Details',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedBusinessType.accountTitle,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedBusinessType.accountSubTitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Selected Industry Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SELECTED INDUSTRY',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                            ),
                            Text(
                              _selectedBusinessType.displayName,
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Change', style: TextStyle(color: AppTheme.primary, fontSize: 12.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Name & Surname
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'First Name',
                        hint: 'e.g. Carlos',
                        controller: _firstNameController,
                        prefixIcon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Last Name',
                        hint: 'e.g. Rodriguez',
                        controller: _lastNameController,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dynamic Business Shop Details
                CustomTextField(
                  label: _selectedBusinessType.shopFieldLabel,
                  hint: _selectedBusinessType.shopFieldHint,
                  controller: _shopNameController,
                  prefixIcon: Icons.storefront_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return _selectedBusinessType.shopValidationMsg;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Shop Location',
                  hint: 'e.g. 45 Main St, Suite 102',
                  controller: _shopLocationController,
                  prefixIcon: Icons.location_on_outlined,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your shop location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone & Email
                CustomTextField(
                  label: 'Phone Number',
                  hint: 'e.g. +1 (555) 234-5678',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Email Address',
                  hint: _selectedBusinessType.emailHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password & Confirmation
                CustomTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Confirm Password',
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_clock_outlined,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Action Button
                CustomButton(
                  text: 'Continue to Plan Selection',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _onContinue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
