import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class IndustrySelectorWidget extends StatelessWidget {
  final BusinessType selectedType;
  final ValueChanged<BusinessType> onTypeSelected;

  const IndustrySelectorWidget({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Profession / Industry',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Configures your default service catalog and client experience',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: BusinessType.values.map((type) {
              final isSelected = type == selectedType;
              IconData icon;
              String subtitle;

              switch (type) {
                case BusinessType.barberShop:
                  icon = Icons.content_cut_rounded;
                  subtitle = 'Haircuts & Beard Care';
                  break;
                case BusinessType.hairSalon:
                  icon = Icons.face_3_rounded;
                  subtitle = 'Hair Styling & Color';
                  break;
                case BusinessType.nailStudio:
                  icon = Icons.clean_hands_rounded;
                  subtitle = 'Manicure & Pedicure';
                  break;
                case BusinessType.lashAndBrow:
                  icon = Icons.visibility_rounded;
                  subtitle = 'Lashes & Brows';
                  break;
                case BusinessType.esthetician:
                  icon = Icons.spa_rounded;
                  subtitle = 'Facials & Skin Care';
                  break;
              }

              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  onTap: () => onTypeSelected(type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryLight : AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.borderColor,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: isSelected ? AppTheme.primary : AppTheme.surfaceLight,
                          child: Icon(
                            icon,
                            color: isSelected ? Colors.white : AppTheme.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              type.displayName,
                              style: TextStyle(
                                color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
