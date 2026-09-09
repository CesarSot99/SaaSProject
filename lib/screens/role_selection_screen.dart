import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import 'admin/super_admin_main_shell.dart';
import 'customer_register_screen.dart';
import 'login_screen.dart';
import 'profession_selection_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const AppLogo(iconSize: 46, fontSize: 26),
              const SizedBox(height: 14),
              
              // Concise & Professional Hero Headline
              const Text(
                'Welcome to BarberSync',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              
              // Secondary Subtext
              Text(
                'Choose your account type to get started',
                style: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.85),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Role Card: Stylist
              _RoleCard(
                title: 'Stylist',
                badgeText: 'FOR PROFESSIONALS',
                subtitle: 'Manage your appointments, set custom services & prices, track daily income, and handle tax estimates.',
                featurePills: const ['💈 Schedule Control', '💰 Income & Taxes', '📱 Client CRM'],
                icon: Icons.content_cut_rounded,
                accentColor: AppTheme.primary,
                gradientColors: [
                  AppTheme.primary.withValues(alpha: 0.12),
                  AppTheme.tertiary.withValues(alpha: 0.06),
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfessionSelectionScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // Role Card: Client
              _RoleCard(
                title: 'Client',
                badgeText: 'FOR CLIENTS',
                subtitle: 'Book appointments instantly, select preferred services, view past haircut history, and receive direct updates.',
                featurePills: const ['⚡ Instant Booking', '📲 Direct Link', '🔔 Auto Reminders'],
                icon: Icons.person_rounded,
                accentColor: AppTheme.success,
                gradientColors: [
                  AppTheme.success.withValues(alpha: 0.12),
                  AppTheme.accent.withValues(alpha: 0.06),
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomerRegisterScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Platform Owner Portal discrete access button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SuperAdminMainShell(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings_rounded, size: 15, color: AppTheme.tertiary),
                  label: const Text(
                    'SaaS Platform Owner Portal',
                    style: TextStyle(
                      color: AppTheme.tertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String title;
  final String badgeText;
  final String subtitle;
  final List<String> featurePills;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.badgeText,
    required this.subtitle,
    required this.featurePills,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isHovered
                ? [
                    widget.accentColor.withValues(alpha: 0.18),
                    widget.accentColor.withValues(alpha: 0.08),
                  ]
                : [
                    AppTheme.surface,
                    AppTheme.surfaceLight,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _isHovered ? widget.accentColor : widget.accentColor.withValues(alpha: 0.35),
            width: _isHovered ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withValues(alpha: _isHovered ? 0.25 : 0.08),
              blurRadius: _isHovered ? 24 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Icon + Badge + Arrow
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.accentColor.withValues(alpha: 0.25),
                              widget.accentColor.withValues(alpha: 0.10),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.accentColor.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.accentColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: widget.accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.badgeText,
                                style: TextStyle(
                                  color: widget.accentColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isHovered ? widget.accentColor : widget.accentColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: _isHovered ? Colors.white : widget.accentColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Subtitle Description
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Feature Pills Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: widget.featurePills.map((pill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.background.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.accentColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          pill,
                          style: TextStyle(
                            color: AppTheme.textPrimary.withValues(alpha: 0.9),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
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
