import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BarberInfoCard extends StatelessWidget {
  final String barberName;
  final String shopName;
  final String location;
  final String publicCode;
  final String professionalTitle;
  final VoidCallback? onDirectionsTap;

  const BarberInfoCard({
    super.key,
    this.barberName = 'Carlos Rodríguez',
    this.shopName = 'Carlos Barber Studio',
    this.location = 'Lawrence, MA',
    this.publicCode = 'BARB-7X92K',
    this.professionalTitle = 'Barber',
    this.onDirectionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                child: const Icon(Icons.content_cut_rounded, color: AppTheme.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barberName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      shopName,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.tertiary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Phone: $publicCode',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    location,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onDirectionsTap ?? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening Barber Studio directions in Maps...'),
                      backgroundColor: AppTheme.surface,
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'Directions',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.directions_outlined, color: AppTheme.primary, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
