import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'barber_code_display_screen.dart';

class BarberPaymentScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String shopName;
  final String shopLocation;
  final String phone;
  final String email;
  final String password;
  final SubscriptionPlan selectedPlan;
  final BusinessType businessType;

  const BarberPaymentScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.shopName,
    required this.shopLocation,
    required this.phone,
    required this.email,
    required this.password,
    required this.selectedPlan,
    this.businessType = BusinessType.barberShop,
  });

  @override
  State<BarberPaymentScreen> createState() => _BarberPaymentScreenState();
}

class _BarberPaymentScreenState extends State<BarberPaymentScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _paymentMethod = 'card';

  Future<void> _processPaymentAndActivate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final barber = await _authService.registerBarber(
        firstName: widget.firstName,
        lastName: widget.lastName,
        shopName: widget.shopName,
        shopLocation: widget.shopLocation,
        phone: widget.phone,
        email: widget.email,
        password: widget.password,
        planId: widget.selectedPlan.id,
        businessType: widget.businessType,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => BarberCodeDisplayScreen(barber: barber),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
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
    final now = DateTime.now();
    final nextBilling = now.add(const Duration(days: 30));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment & Subscription'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, size: 16, color: AppTheme.success),
                    SizedBox(width: 6),
                    Text(
                      'Step 3 of 3: Confirmation & Activation',
                      style: TextStyle(
                        color: AppTheme.success,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Subscription Summary',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Review your plan details and select your payment method.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Subscription Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.secondary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.selectedPlan.name,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Monthly billing',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '\$${widget.selectedPlan.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 28),
                    _SummaryRow(
                      label: '${widget.businessType.professionalTitle}:',
                      value: '${widget.firstName} ${widget.lastName}',
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: '${widget.businessType.shopFieldLabel}:',
                      value: widget.shopName,
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Start Date:',
                      value: '${now.month}/${now.day}/${now.year}',
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Next Billing:',
                      value: '${nextBilling.month}/${nextBilling.day}/${nextBilling.year}',
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Account Status:',
                      valueWidget: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.success.withValues(alpha: 0.5)),
                        ),
                        child: const Text(
                          'ACTIVE (Upon confirmation)',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                'Payment Method (Simulation)',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _PaymentOptionTile(
                title: 'Credit / Debit Card',
                subtitle: 'Visa, Mastercard, Amex',
                icon: Icons.credit_card_rounded,
                isSelected: _paymentMethod == 'card',
                onTap: () => setState(() => _paymentMethod = 'card'),
              ),
              const SizedBox(height: 10),
              _PaymentOptionTile(
                title: 'Mobile Pay / Wire Transfer',
                subtitle: 'Fast and instant confirmation',
                icon: Icons.mobile_friendly_rounded,
                isSelected: _paymentMethod == 'mobile_pay',
                onTap: () => setState(() => _paymentMethod = 'mobile_pay'),
              ),
              const SizedBox(height: 10),
              _PaymentOptionTile(
                title: 'Zelle / International Pay',
                subtitle: 'Direct USD payment',
                icon: Icons.account_balance_rounded,
                isSelected: _paymentMethod == 'zelle',
                onTap: () => setState(() => _paymentMethod = 'zelle'),
              ),

              const SizedBox(height: 32),

              CustomButton(
                text: 'Confirm Payment & Activate Account',
                icon: Icons.check_circle_rounded,
                isLoading: _isLoading,
                onPressed: _processPaymentAndActivate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _SummaryRow({
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13.5,
          ),
        ),
        if (value case final String val)
          Text(
            val,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (valueWidget case final Widget widget) widget,
      ],
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppTheme.surfaceLight : AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.secondary.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.secondary, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                color: isSelected ? AppTheme.primary : AppTheme.secondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
