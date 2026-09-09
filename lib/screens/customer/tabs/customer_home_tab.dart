import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/barber_data_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/barber_info_card.dart';
import '../../../widgets/notification_bell_button.dart';
import '../../../widgets/status_badge.dart';

class CustomerHomeTab extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const CustomerHomeTab({
    super.key,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final dataService = BarberDataService();
    final customer = authService.currentUser as CustomerUser?;

    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final appointments = dataService.appointments
            .where((a) => a.customerId == (customer?.internalId ?? 'UID-CUST-101'))
            .toList();

        // Next upcoming appointment (in progress, confirmed or pending)
        final upcomingApts = appointments
            .where((a) =>
                a.status == AppointmentStatus.inProgress ||
                a.status == AppointmentStatus.confirmed ||
                a.status == AppointmentStatus.pending)
            .toList();

        AppointmentModel? nextApt = upcomingApts.isNotEmpty ? upcomingApts.first : null;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Header (Spec #34)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppTheme.tertiary.withValues(alpha: 0.2),
                        child: const Icon(Icons.person_rounded, color: AppTheme.tertiary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${customer?.firstName ?? "John"} 👋',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Welcome back to BarberSync',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const NotificationBellButton(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Associated Stylist Card (Spec #4 & #19)
                  const Text(
                    'MY STYLIST',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BarberInfoCard(
                    barberName: customer?.assignedBarberName ?? 'Carlos Rodríguez',
                    publicCode: customer?.assignedBarberPhone ?? '+1 (555) 987-6543',
                  ),

                  const SizedBox(height: 24),

                  // Next Upcoming Appointment Highlight Badge (Spec #2 & #34)
                  const Text(
                    'NEXT APPOINTMENT',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (nextApt != null)
                    _NextAppointmentHighlightCard(
                      appointment: nextApt,
                      onViewDetails: () => onNavigateToTab?.call(2), // Switch to Appointments tab
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: AppTheme.primary, size: 32),
                          const SizedBox(height: 10),
                          const Text(
                            'No upcoming appointments scheduled',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Book your next haircut in seconds with your barber.',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: () => onNavigateToTab?.call(1), // Switch to Book tab
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Book Appointment Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Quick Action Shortcuts Bar (Spec #33 & #34)
                  const Text(
                    'QUICK ACTIONS',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          title: 'Book Appointment',
                          subtitle: 'Select service & time',
                          icon: Icons.calendar_month_rounded,
                          color: AppTheme.primary,
                          onTap: () => onNavigateToTab?.call(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          title: 'My Appointments',
                          subtitle: 'View active bookings',
                          icon: Icons.bookmark_added_rounded,
                          color: AppTheme.tertiary,
                          onTap: () => onNavigateToTab?.call(2),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Recent Activity Tile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onNavigateToTab?.call(3), // Switch to History tab
                        child: const Text('View All', style: TextStyle(color: AppTheme.primary, fontSize: 13)),
                      ),
                    ],
                  ),

                  if (appointments.isEmpty)
                    const Text('No recent activity.', style: TextStyle(color: AppTheme.textMuted))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: appointments.take(3).length,
                      itemBuilder: (context, index) {
                        final apt = appointments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                              child: const Icon(Icons.content_cut_rounded, color: AppTheme.primary, size: 18),
                            ),
                            title: Text(
                              apt.serviceName,
                              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              '${apt.dateTime.month}/${apt.dateTime.day}/${apt.dateTime.year} • \$${apt.basePrice.toStringAsFixed(0)}',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                            trailing: StatusBadge(status: apt.status),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NextAppointmentHighlightCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onViewDetails;

  const _NextAppointmentHighlightCard({
    required this.appointment,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.surface, AppTheme.surfaceLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.12),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_filled_rounded, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${appointment.dateTime.month}/${appointment.dateTime.day} • ${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')} PM',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              StatusBadge(status: appointment.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            appointment.serviceName,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Duration: ${appointment.durationMinutes} min • Price: \$${appointment.basePrice.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onViewDetails,
            icon: const Icon(Icons.info_outline_rounded, size: 16),
            label: const Text('View Booking Details'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary),
              minimumSize: const Size(double.infinity, 38),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
