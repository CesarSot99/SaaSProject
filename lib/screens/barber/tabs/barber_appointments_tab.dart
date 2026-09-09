import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../services/barber_data_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/complete_service_modal.dart';
import '../../../widgets/reschedule_appointment_modal.dart';
import '../../../widgets/status_badge.dart';

class BarberAppointmentsTab extends StatefulWidget {
  const BarberAppointmentsTab({super.key});

  @override
  State<BarberAppointmentsTab> createState() => _BarberAppointmentsTabState();
}

class _BarberAppointmentsTabState extends State<BarberAppointmentsTab> {
  final BarberDataService _dataService = BarberDataService();

  String _viewMode = 'TIMELINE'; // 'TIMELINE' or 'LIST'
  String _selectedStatusFilter = 'ALL';
  DateTime _selectedDate = DateTime.now();

  final List<int> _timelineHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _dataService,
      builder: (context, _) {
        final allAppointments = _dataService.appointments;

        final filteredAppointments = allAppointments.where((apt) {
          if (_selectedStatusFilter == 'PENDING') {
            return apt.status == AppointmentStatus.pending;
          } else if (_selectedStatusFilter == 'CONFIRMED') {
            return apt.status == AppointmentStatus.confirmed;
          } else if (_selectedStatusFilter == 'IN_PROGRESS') {
            return apt.status == AppointmentStatus.inProgress;
          } else if (_selectedStatusFilter == 'COMPLETED') {
            return apt.status == AppointmentStatus.completed;
          } else if (_selectedStatusFilter == 'CANCELED') {
            return apt.status == AppointmentStatus.canceled || apt.status == AppointmentStatus.noShow;
          }
          return true;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Appointments & Calendar'),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: AppTheme.primary),
                tooltip: 'Filter Options',
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 1. Segmented View Switcher (Timeline / List)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _viewMode = 'TIMELINE'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _viewMode == 'TIMELINE' ? AppTheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: _viewMode == 'TIMELINE'
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primary.withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.view_timeline_rounded,
                                    size: 16,
                                    color: _viewMode == 'TIMELINE' ? Colors.white : AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Timeline',
                                    style: TextStyle(
                                      color: _viewMode == 'TIMELINE' ? Colors.white : AppTheme.textSecondary,
                                      fontSize: 13.5,
                                      fontWeight: _viewMode == 'TIMELINE' ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _viewMode = 'LIST'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _viewMode == 'LIST' ? AppTheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: _viewMode == 'LIST'
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primary.withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.format_list_bulleted_rounded,
                                    size: 16,
                                    color: _viewMode == 'LIST' ? Colors.white : AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'List View',
                                    style: TextStyle(
                                      color: _viewMode == 'LIST' ? Colors.white : AppTheme.textSecondary,
                                      fontSize: 13.5,
                                      fontWeight: _viewMode == 'LIST' ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 2. Date Selector Header Card (Month + Days Bar)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _getMonthName(_selectedDate.month),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
                            ],
                          ),
                          const Icon(Icons.view_week_rounded, color: AppTheme.textSecondary, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          final date = DateTime.now().add(Duration(days: index - 2));
                          final isSelected = date.day == _selectedDate.day;

                          final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                          final dayName = dayNames[date.weekday % 7];

                          return GestureDetector(
                            onTap: () => setState(() => _selectedDate = date),
                            child: Column(
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.primary.withValues(alpha: 0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      date.day.toString().padLeft(2, '0'),
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Filter Chips Scrollable Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All (${allAppointments.length})',
                        isSelected: _selectedStatusFilter == 'ALL',
                        onTap: () => setState(() => _selectedStatusFilter = 'ALL'),
                      ),
                      _FilterChip(
                        label: 'Pending (${allAppointments.where((a) => a.status == AppointmentStatus.pending).length})',
                        isSelected: _selectedStatusFilter == 'PENDING',
                        color: AppTheme.warning,
                        onTap: () => setState(() => _selectedStatusFilter = 'PENDING'),
                      ),
                      _FilterChip(
                        label: 'Confirmed (${allAppointments.where((a) => a.status == AppointmentStatus.confirmed).length})',
                        isSelected: _selectedStatusFilter == 'CONFIRMED',
                        color: AppTheme.primary,
                        onTap: () => setState(() => _selectedStatusFilter = 'CONFIRMED'),
                      ),
                      _FilterChip(
                        label: 'In Progress (${allAppointments.where((a) => a.status == AppointmentStatus.inProgress).length})',
                        isSelected: _selectedStatusFilter == 'IN_PROGRESS',
                        color: AppTheme.tertiary,
                        onTap: () => setState(() => _selectedStatusFilter = 'IN_PROGRESS'),
                      ),
                      _FilterChip(
                        label: 'Completed (${allAppointments.where((a) => a.status == AppointmentStatus.completed).length})',
                        isSelected: _selectedStatusFilter == 'COMPLETED',
                        color: AppTheme.success,
                        onTap: () => setState(() => _selectedStatusFilter = 'COMPLETED'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 3. Body View: Vertical Timeline or List View
                Expanded(
                  child: _viewMode == 'TIMELINE'
                      ? _buildVerticalTimelineView(filteredAppointments)
                      : _buildListView(filteredAppointments),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Vertical Timeline View
  Widget _buildVerticalTimelineView(List<AppointmentModel> appointments) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 30),
      itemCount: _timelineHours.length,
      itemBuilder: (context, index) {
        final hour = _timelineHours[index];
        final hourLabel = hour > 12 ? '${hour - 12} PM' : (hour == 12 ? '12 PM' : '$hour AM');

        // Find appointments for this hour slot
        final hourAppointments = appointments.where((a) => a.dateTime.hour == hour).toList();

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hour Label Side
                SizedBox(
                  width: 55,
                  child: Text(
                    hourLabel,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Timeline Divider Line & Content Block
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 1,
                        color: AppTheme.secondary.withValues(alpha: 0.3),
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                      ),

                      if (hourAppointments.isEmpty)
                        const SizedBox(height: 48)
                      else
                        ...hourAppointments.map((apt) => _TimelineAppointmentBlock(
                              appointment: apt,
                              onConfirm: () => _dataService.confirmAppointment(apt.id),
                              onStart: () => _dataService.startService(apt.id),
                              onComplete: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => CompleteServiceModal(appointment: apt),
                                );
                              },
                            )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Standard List View
  Widget _buildListView(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, size: 48, color: AppTheme.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text('No appointments found for this filter.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final apt = appointments[index];
        return _DetailedAppointmentCard(
          appointment: apt,
          onConfirm: () => _dataService.confirmAppointment(apt.id),
          onReject: () => _dataService.rejectAppointment(apt.id),
          onStart: () => _dataService.startService(apt.id),
          onComplete: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => CompleteServiceModal(appointment: apt),
            );
          },
          onNoShow: () => _dataService.markNoShow(apt.id),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}

// Vertical Timeline Block Component (Cyan Breeze Soft Light Theme)
class _TimelineAppointmentBlock extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onConfirm;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  const _TimelineAppointmentBlock({
    required this.appointment,
    required this.onConfirm,
    required this.onStart,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    Color cardBg;
    Color accentBarColor;
    Color textAccentColor;

    switch (appointment.status) {
      case AppointmentStatus.pending:
        cardBg = const Color(0xFFFFFBEB);
        accentBarColor = AppTheme.warning;
        textAccentColor = const Color(0xFFD97706);
        break;
      case AppointmentStatus.confirmed:
        cardBg = AppTheme.primaryLight;
        accentBarColor = AppTheme.primary;
        textAccentColor = AppTheme.primaryDark;
        break;
      case AppointmentStatus.inProgress:
        cardBg = AppTheme.accentLight;
        accentBarColor = AppTheme.accent;
        textAccentColor = AppTheme.accentDark;
        break;
      case AppointmentStatus.completed:
        cardBg = const Color(0xFFF0FDF4);
        accentBarColor = AppTheme.success;
        textAccentColor = AppTheme.success;
        break;
      case AppointmentStatus.canceled:
      case AppointmentStatus.noShow:
        cardBg = const Color(0xFFFEF2F2);
        accentBarColor = AppTheme.error;
        textAccentColor = AppTheme.error;
        break;
    }

    final formattedTime = '${appointment.dateTime.hour > 12 ? appointment.dateTime.hour - 12 : appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')} ${appointment.dateTime.hour >= 12 ? 'PM' : 'AM'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentBarColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: accentBarColor.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Solid Left Edge Accent Bar
              Container(
                width: 6,
                color: accentBarColor,
              ),

              // Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 14, color: textAccentColor),
                              const SizedBox(width: 4),
                              Text(
                                '${appointment.dateTime.day} ${_getMonthShort(appointment.dateTime.month)} | $formattedTime',
                                style: TextStyle(
                                  color: textAccentColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          StatusBadge(status: appointment.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person_rounded, size: 16, color: AppTheme.textPrimary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${appointment.customerName} • ${appointment.serviceName}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appointment.durationMinutes} min • \$${appointment.basePrice.toStringAsFixed(0)}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
                      ),

                      if (appointment.status == AppointmentStatus.pending ||
                          appointment.status == AppointmentStatus.confirmed ||
                          appointment.status == AppointmentStatus.inProgress) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (appointment.status == AppointmentStatus.pending)
                              ElevatedButton.icon(
                                onPressed: onConfirm,
                                icon: const Icon(Icons.check_rounded, size: 15),
                                label: const Text('Confirm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              )
                            else if (appointment.status == AppointmentStatus.confirmed)
                              ElevatedButton.icon(
                                onPressed: onStart,
                                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                                label: const Text('Start Service', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              )
                            else if (appointment.status == AppointmentStatus.inProgress)
                              ElevatedButton.icon(
                                onPressed: onComplete,
                                icon: const Icon(Icons.task_alt_rounded, size: 16),
                                label: const Text('Complete Service', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.success,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),

                            // Reschedule Option
                            OutlinedButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => RescheduleAppointmentModal(appointment: appointment),
                                );
                              },
                              icon: const Icon(Icons.edit_calendar_rounded, size: 14),
                              label: const Text('Reschedule', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                                side: const BorderSide(color: AppTheme.primary),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),

                            // Mark as No-Show Option for Confirmed
                            if (appointment.status == AppointmentStatus.confirmed || appointment.status == AppointmentStatus.pending)
                              OutlinedButton.icon(
                                onPressed: () {
                                  BarberDataService().markNoShow(appointment.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Appointment marked as No-Show.'),
                                      backgroundColor: AppTheme.error,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.person_off_outlined, size: 14),
                                label: const Text('No Show', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.error,
                                  side: const BorderSide(color: AppTheme.error),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                          ],
                        ),
                      ],
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

  String _getMonthShort(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
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

class _DetailedAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onNoShow;

  const _DetailedAppointmentCard({
    required this.appointment,
    required this.onConfirm,
    required this.onReject,
    required this.onStart,
    required this.onComplete,
    required this.onNoShow,
  });

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.access_time_rounded, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')} PM (${appointment.durationMinutes} min)',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
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
            appointment.customerName,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
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
    );
  }
}

