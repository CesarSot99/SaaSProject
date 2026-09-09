import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'customer/customer_main_shell.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _barberCodeController = TextEditingController();

  BarberUser? _validatedBarber;
  String? _codeErrorMessage;
  bool _isValidatingCode = false;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _barberCodeController.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _barberCodeController.removeListener(_onCodeChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _barberCodeController.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    final code = _barberCodeController.text.trim();
    if (code.length >= 6) {
      _validateCode(code);
    } else {
      if (_validatedBarber != null || _codeErrorMessage != null) {
        setState(() {
          _validatedBarber = null;
          _codeErrorMessage = null;
        });
      }
    }
  }

  void _validateCode(String code) {
    setState(() {
      _isValidatingCode = true;
    });

    final barber = _authService.validateBarberCode(code);

    setState(() {
      _isValidatingCode = false;
      if (barber != null) {
        _validatedBarber = barber;
        _codeErrorMessage = null;
      } else {
        _validatedBarber = null;
        _codeErrorMessage = 'No registered stylist found with this phone number. Please check and try again.';
      }
    });
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final code = _barberCodeController.text.trim();
    _validateCode(code);

    if (_validatedBarber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_codeErrorMessage ?? 'You must enter a valid barber code to continue.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      await _authService.registerCustomer(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        barberCode: code,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomerMainShell(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRegistering = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Registration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.tertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.tertiary.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_pin_rounded, size: 16, color: AppTheme.tertiary),
                      SizedBox(width: 6),
                      Text(
                        'Linked Client Registration',
                        style: TextStyle(
                          color: AppTheme.tertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Create your Client Account',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your details and your barber\'s unique code to link directly with them.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Barber Code Section (Obligatory)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _validatedBarber != null
                          ? AppTheme.success
                          : (_codeErrorMessage != null
                              ? AppTheme.error
                              : AppTheme.tertiary.withValues(alpha: 0.4)),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.phone_iphone_rounded, color: AppTheme.tertiary, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            "Stylist's Phone Number (Required)",
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_isValidatingCode)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.tertiary),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _barberCodeController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. (555) 987-6543',
                          hintStyle: TextStyle(
                            color: AppTheme.textMuted.withValues(alpha: 0.6),
                            fontSize: 16,
                            letterSpacing: 1.0,
                          ),
                          helperText: 'Default test code: BARB-7X92K',
                          helperStyle: const TextStyle(color: AppTheme.primary, fontSize: 11.5),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search_rounded, color: AppTheme.tertiary),
                            onPressed: () => _validateCode(_barberCodeController.text.trim()),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Barber code is required';
                          }
                          return null;
                        },
                      ),

                      // Valid Barber Card Preview
                      if (_validatedBarber != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.success.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Barber Found:',
                                      style: TextStyle(
                                        color: AppTheme.success,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _validatedBarber!.fullName,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${_validatedBarber!.shopName} • ${_validatedBarber!.shopLocation}',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Invalid Code Error Banner
                      if (_codeErrorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.error.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _codeErrorMessage!,
                                  style: const TextStyle(
                                    color: AppTheme.error,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Name & Surname
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'First Name',
                        hint: 'e.g. John',
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
                        hint: 'e.g. Smith',
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

                // Phone & Email
                CustomTextField(
                  label: 'Phone Number',
                  hint: 'e.g. +1 (555) 987-6543',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Email Address',
                  hint: 'john@client.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Passwords
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
                      return 'Minimum 6 characters';
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

                // Submit Button
                CustomButton(
                  text: 'Complete Registration & Link',
                  variant: ButtonVariant.tertiary,
                  icon: Icons.check_circle_rounded,
                  isLoading: _isRegistering,
                  onPressed: _onRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
