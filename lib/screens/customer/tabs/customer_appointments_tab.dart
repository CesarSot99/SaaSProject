import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/barber_data_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/reschedule_appointment_modal.dart';
import '../../../widgets/status_badge.dart';

class CustomerAppointmentsTab extends StatefulWidget {
  const CustomerAppointmentsTab({super.key});

  @override
  State<CustomerAppointmentsTab> createState() => _CustomerAppointmentsTabState();
}

class _CustomerAppointmentsTabState extends State<CustomerAppointmentsTab> {
  final AuthService _authService = AuthService();
  final BarberDataService _dataService = BarberDataService();

  String _selectedFilter = 'ALL'; // 'ALL', 'PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELED'

  void _showCancelConfirmation(BuildContext context, AppointmentModel apt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Cancel Appointment?', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Are you sure you want to cancel your ${apt.serviceName} appointment on ${apt.dateTime.month}/${apt.dateTime.day} at ${apt.dateTime.hour}:${apt.dateTime.minute.toString().padLeft(2, '0')} PM?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Appointment', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              _dataService.cancelAppointmentByCustomer(apt.id, reason: 'Canceled by customer');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment has been canceled.'),
                  backgroundColor: AppTheme.warning,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = _authService.currentUser as CustomerUser?;
    final customerId = customer?.internalId ?? 'UID-CUST-101';

    return ListenableBuilder(
      listenable: _dataService,
      builder: (context, _) {
        final allCustomerApts = _dataService.appointments
            .where((a) => a.customerId == customerId)
            .toList();

        final filteredApts = allCustomerApts.where((apt) {
          if (_selectedFilter == 'PENDING') return apt.status == AppointmentStatus.pending;
          if (_selectedFilter == 'CONFIRMED') return apt.status == AppointmentStatus.confirmed || apt.status == AppointmentStatus.inProgress;
          if (_selectedFilter == 'COMPLETED') return apt.status == AppointmentStatus.completed;
          if (_selectedFilter == 'CANCELED') return apt.status == AppointmentStatus.canceled || apt.status == AppointmentStatus.noShow;
          return true;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Appointments'),
            centerTitle: false,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    children: [
                      _FilterTabChip(
                        label: 'All (${allCustomerApts.length})',
                        isSelected: _selectedFilter == 'ALL',
                        onTap: () => setState(() => _selectedFilter = 'ALL'),
                      ),
                      _FilterTabChip(
                        label: 'Pending (${allCustomerApts.where((a) => a.status == AppointmentStatus.pending).length})',
                        isSelected: _selectedFilter == 'PENDING',
                        color: AppTheme.warning,
                        onTap: () => setState(() => _selectedFilter = 'PENDING'),
                      ),
                      _FilterTabChip(
                        label: 'Confirmed (${allCustomerApts.where((a) => a.status == AppointmentStatus.confirmed).length})',
                        isSelected: _selectedFilter == 'CONFIRMED',
                        color: AppTheme.primary,
                        onTap: () => setState(() => _selectedFilter = 'CONFIRMED'),
                      ),
                      _FilterTabChip(
                        label: 'Completed (${allCustomerApts.where((a) => a.status == AppointmentStatus.completed).length})',
                        isSelected: _selectedFilter == 'COMPLETED',
                        color: AppTheme.success,
                        onTap: () => setState(() => _selectedFilter = 'COMPLETED'),
                      ),
                      _FilterTabChip(
                        label: 'Canceled / No Show',
                        isSelected: _selectedFilter == 'CANCELED',
                        color: AppTheme.error,
                        onTap: () => setState(() => _selectedFilter = 'CANCELED'),
                      ),
                    ],
                  ),
                ),

                Divider(color: AppTheme.secondary.withValues(alpha: 0.3), height: 16),

                // Appointments List
                Expanded(
                  child: filteredApts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy_rounded, size: 48, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              const Text(
                                'No appointments found in this section.',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          itemCount: filteredApts.length,
                          itemBuilder: (context, index) {
                            final apt = filteredApts[index];
                            final canCancel = apt.status == AppointmentStatus.pending || apt.status == AppointmentStatus.confirmed;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
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
                                          const Icon(Icons.access_time_rounded, color: AppTheme.primary, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${apt.dateTime.month}/${apt.dateTime.day}/${apt.dateTime.year} • ${apt.dateTime.hour}:${apt.dateTime.minute.toString().padLeft(2, '0')} PM',
                                            style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      StatusBadge(status: apt.status),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  Text(
                                    apt.serviceName,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.content_cut_rounded, size: 14, color: AppTheme.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Barber: Carlos Rodríguez • ${apt.durationMinutes} min • \$${apt.basePrice.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: AppTheme.primary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (apt.customerNotes != null && apt.customerNotes!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Your Note: "${apt.customerNotes}"',
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                      ),
                                    ),
                                  ],

                                  if (canCancel) ...[
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor: Colors.transparent,
                                                builder: (context) => RescheduleAppointmentModal(appointment: apt),
                                              );
                                            },
                                            icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                                            label: const Text('Reschedule'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppTheme.primary,
                                              side: const BorderSide(color: AppTheme.primary, width: 1.2),
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _showCancelConfirmation(context, apt),
                                            icon: const Icon(Icons.cancel_outlined, size: 16),
                                            label: const Text('Cancel'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppTheme.error,
                                              side: const BorderSide(color: AppTheme.error, width: 1.2),
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterTabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterTabChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? chipColor.withValues(alpha: 0.15) : AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? chipColor : AppTheme.secondary.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? chipColor : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

