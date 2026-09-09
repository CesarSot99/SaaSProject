import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import 'barber_register_screen.dart';

class ProfessionSelectionScreen extends StatelessWidget {
  const ProfessionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final professions = [
      _ProfessionOption(
        title: 'Barber Shop',
        badgeText: 'MOST POPULAR',
        subtitle: 'Haircuts, Fades, Beard Care & Hot Towel Shaves',
        featurePills: const ['💈 Fades & Beards', '✂️ Barber Services'],
        icon: Icons.content_cut_rounded,
        accentColor: AppTheme.primary,
        gradientColors: [
          AppTheme.primary.withValues(alpha: 0.15),
          AppTheme.tertiary.withValues(alpha: 0.05),
        ],
      ),
      _ProfessionOption(
        title: 'Hair & Beauty Salon',
        badgeText: 'SALON PRO',
        subtitle: 'Hair Styling, Coloring, Balayage, Cuts & Blowouts',
        featurePills: const ['💇‍♀️ Styling & Color', '✨ Hair Care'],
        icon: Icons.face_retouching_natural_rounded,
        accentColor: AppTheme.tertiary,
        gradientColors: [
          AppTheme.tertiary.withValues(alpha: 0.15),
          AppTheme.accent.withValues(alpha: 0.05),
        ],
      ),
      _ProfessionOption(
        title: 'Nail Studio & Spa',
        badgeText: 'NAIL TECH',
        subtitle: 'Manicure, Pedicure, Gel Extensions, Acrylics & Art',
        featurePills: const ['💅 Mani & Pedi', '🎨 Acrylics & Art'],
        icon: Icons.clean_hands_rounded,
        accentColor: const Color(0xFF0284C7),
        gradientColors: [
          const Color(0xFF0284C7).withValues(alpha: 0.15),
          AppTheme.primary.withValues(alpha: 0.05),
        ],
      ),
      _ProfessionOption(
        title: 'Lash & Brow Studio',
        badgeText: 'BEAUTY TECH',
        subtitle: 'Eyelash Extensions, Lash Lifts, Brow Lamination & Tint',
        featurePills: const ['👁️ Lashes & Brows', '✨ Lamination'],
        icon: Icons.remove_red_eye_rounded,
        accentColor: AppTheme.accent,
        gradientColors: [
          AppTheme.accent.withValues(alpha: 0.15),
          AppTheme.tertiary.withValues(alpha: 0.05),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Step 1 of 3'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppLogo(iconSize: 48, fontSize: 28),
              const SizedBox(height: 16),

              const Text(
                'Select Your Profession / Industry',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Configures your default service catalog, branding, and client booking experience',
                style: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.85),
                  fontSize: 13.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: professions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final option = professions[index];
                  return _ProfessionCard(
                    option: option,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BarberRegisterScreen(
                            initialProfession: option.title,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfessionOption {
  final String title;
  final String badgeText;
  final String subtitle;
  final List<String> featurePills;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;

  const _ProfessionOption({
    required this.title,
    required this.badgeText,
    required this.subtitle,
    required this.featurePills,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
  });
}

class _ProfessionCard extends StatefulWidget {
  final _ProfessionOption option;
  final VoidCallback onTap;

  const _ProfessionCard({
    required this.option,
    required this.onTap,
  });

  @override
  State<_ProfessionCard> createState() => _ProfessionCardState();
}

class _ProfessionCardState extends State<_ProfessionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final option = widget.option;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isHovered
                ? [
                    option.accentColor.withValues(alpha: 0.18),
                    option.accentColor.withValues(alpha: 0.08),
                  ]
                : [
                    AppTheme.surface,
                    AppTheme.surfaceLight,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? option.accentColor : option.accentColor.withValues(alpha: 0.3),
            width: _isHovered ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: option.accentColor.withValues(alpha: _isHovered ? 0.22 : 0.06),
              blurRadius: _isHovered ? 20 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          option.accentColor.withValues(alpha: 0.25),
                          option.accentColor.withValues(alpha: 0.10),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: option.accentColor.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      option.icon,
                      color: option.accentColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title + Subtitle + Pills
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              option.title,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: option.accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                option.badgeText,
                                style: TextStyle(
                                  color: option.accentColor,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          option.subtitle,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: option.featurePills.map((pill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.background.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: option.accentColor.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                pill,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Action Arrow
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isHovered ? option.accentColor : option.accentColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _isHovered ? Colors.white : option.accentColor,
                      size: 16,
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
