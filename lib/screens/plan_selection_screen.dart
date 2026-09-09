import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'barber_payment_screen.dart';

class PlanSelectionScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String shopName;
  final String shopLocation;
  final String phone;
  final String email;
  final String password;
  final BusinessType businessType;

  const PlanSelectionScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.shopName,
    required this.shopLocation,
    required this.phone,
    required this.email,
    required this.password,
    this.businessType = BusinessType.barberShop,
  });

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  final AuthService _authService = AuthService();
  late String _selectedPlanId;

  @override
  void initState() {
    super.initState();
    // Default to popular plan (Professional Plan)
    _selectedPlanId = _authService.availablePlans
        .firstWhere((p) => p.isPopular, orElse: () => _authService.availablePlans.first)
        .id;
  }

  void _onProceedToPayment() {
    final selectedPlan = _authService.availablePlans.firstWhere((p) => p.id == _selectedPlanId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarberPaymentScreen(
          firstName: widget.firstName,
          lastName: widget.lastName,
          shopName: widget.shopName,
          shopLocation: widget.shopLocation,
          phone: widget.phone,
          email: widget.email,
          password: widget.password,
          selectedPlan: selectedPlan,
          businessType: widget.businessType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plans = _authService.availablePlans;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Selection'),
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
                  color: AppTheme.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.tertiary.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium_rounded, size: 16, color: AppTheme.tertiary),
                    SizedBox(width: 6),
                    Text(
                      'Step 2 of 3: Choose your Subscription Plan',
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
                'Select the ideal plan for you',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Get the essential tools to manage your ${widget.businessType.displayName.toLowerCase()} and grow your client base.',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Plans list
              ...plans.map((plan) {
                final isSelected = plan.id == _selectedPlanId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _PlanCard(
                    plan: plan,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedPlanId = plan.id;
                      });
                    },
                  ),
                );
              }),

              const SizedBox(height: 24),

              CustomButton(
                text: 'Proceed to Payment & Activation',
                icon: Icons.payment_rounded,
                onPressed: _onProceedToPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBorderColor = isSelected
        ? AppTheme.primary
        : (plan.isPopular ? AppTheme.tertiary.withValues(alpha: 0.4) : AppTheme.secondary.withValues(alpha: 0.2));

    return Material(
      color: isSelected ? AppTheme.surfaceLight : AppTheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cardBorderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (plan.isPopular) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.tertiary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'MOST POPULAR',
                                  style: TextStyle(
                                    color: Color(0xFF1A0A2E),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.description,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12.5,
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
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '\$${plan.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    plan.period,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 24),
              ...plan.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
