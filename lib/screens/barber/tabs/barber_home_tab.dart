import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/barber_data_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/complete_service_modal.dart';
import '../../../widgets/notification_bell_button.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/add_expense_modal.dart';

class BarberHomeTab extends StatelessWidget {
  const BarberHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final dataService = BarberDataService();
    final barber = authService.currentUser as BarberUser?;

    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
        final appointments = dataService.appointments;
        final pendingList = appointments.where((a) => a.status == AppointmentStatus.pending).toList();
        final inProgressList = appointments.where((a) => a.status == AppointmentStatus.inProgress).toList();
        final confirmedList = appointments.where((a) => a.status == AppointmentStatus.confirmed).toList();

        // Next upcoming appointment (in progress or confirmed or pending)
        AppointmentModel? nextApt;
        if (inProgressList.isNotEmpty) {
          nextApt = inProgressList.first;
        } else if (confirmedList.isNotEmpty) {
          nextApt = confirmedList.first;
        } else if (pendingList.isNotEmpty) {
          nextApt = pendingList.first;
        }

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Barber Info Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                        child: Icon(barber?.businessType.icon ?? Icons.content_cut_rounded, color: AppTheme.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${barber?.firstName ?? "Carlos"} 👋',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              barber?.shopName ?? 'Elite Barber Shop',
                              style: const TextStyle(
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

                  // Next Appointment Highlight Card (Spec #2)
                  if (nextApt != null) ...[
                    const Text(
                      'NEXT APPOINTMENT',
                      style: TextStyle(
                        color: AppTheme.tertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _NextAppointmentCard(appointment: nextApt),
                    const SizedBox(height: 24),
                  ],

                  // Financial & Activity Quick Metrics (Spec #2)
                  const Text(
                    "TODAY'S OVERVIEW",
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
                        child: _StatCard(
                          title: 'Total Revenue',
                          value: '\$${dataService.todayTotalRevenue.toStringAsFixed(0)}',
                          subtitle: 'Services + Tips',
                          icon: Icons.payments_rounded,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Est. Net Profit',
                          value: '\$${dataService.estimatedNetProfit.toStringAsFixed(0)}',
                          subtitle: 'Income - Expenses',
                          icon: Icons.trending_up_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _MiniStatTile(
                          title: 'Tips Today',
                          value: '\$${dataService.todayTips.toStringAsFixed(0)}',
                          icon: Icons.volunteer_activism_rounded,
                          accentColor: AppTheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const AddExpenseModal(),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: _MiniStatTile(
                            title: 'Expenses',
                            value: '\$${dataService.totalExpensesAmount.toStringAsFixed(0)}',
                            icon: Icons.receipt_long_rounded,
                            accentColor: AppTheme.warning,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniStatTile(
                          title: 'Completed',
                          value: '${dataService.todayCompletedCount}',
                          icon: Icons.check_circle_outline_rounded,
                          accentColor: AppTheme.success,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Today's Schedule Section Header
                  const Text(
                    "Today's Schedule",
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Today's Appointments List
                  if (appointments.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'No appointments scheduled for today.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final apt = appointments[index];
                        return _AppointmentHomeTile(appointment: apt);
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

class _NextAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const _NextAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final dataService = BarberDataService();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.surface, AppTheme.surfaceLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: appointment.status == AppointmentStatus.inProgress
              ? AppTheme.tertiary
              : AppTheme.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (appointment.status == AppointmentStatus.inProgress
                    ? AppTheme.tertiary
                    : AppTheme.primary)
                .withValues(alpha: 0.12),
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
                    '${appointment.formattedTime} (${appointment.durationMinutes} min)',
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
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.tertiary.withValues(alpha: 0.2),
                child: const Icon(Icons.person_rounded, color: AppTheme.tertiary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.customerName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${appointment.serviceName} • \$${appointment.basePrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (appointment.customerNotes != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Note: "${appointment.customerNotes}"',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Action button depending on status
          if (appointment.status == AppointmentStatus.pending)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => dataService.confirmAppointment(appointment.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Confirm', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => dataService.rejectAppointment(appointment.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Decline', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            )
          else if (appointment.status == AppointmentStatus.confirmed)
            ElevatedButton.icon(
              onPressed: () => dataService.startService(appointment.id),
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Start Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.tertiary,
                foregroundColor: const Color(0xFF1E0A38),
                minimumSize: const Size(double.infinity, 42),
              ),
            )
          else if (appointment.status == AppointmentStatus.inProgress)
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CompleteServiceModal(appointment: appointment),
                );
              },
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text('Complete Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: const Color(0xFF070D18),
                minimumSize: const Size(double.infinity, 42),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _MiniStatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _MiniStatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _AppointmentHomeTile extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentHomeTile({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
          child: Text(
            appointment.formattedTime,
            style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          appointment.customerName,
          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          '${appointment.serviceName} • \$${appointment.basePrice.toStringAsFixed(0)}',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
        ),
        trailing: StatusBadge(status: appointment.status),
      ),
    );
  }
}
