import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/barber_data_service.dart';
import '../theme/app_theme.dart';

class RescheduleAppointmentModal extends StatefulWidget {
  final AppointmentModel appointment;

  const RescheduleAppointmentModal({
    super.key,
    required this.appointment,
  });

  @override
  State<RescheduleAppointmentModal> createState() => _RescheduleAppointmentModalState();
}

class _RescheduleAppointmentModalState extends State<RescheduleAppointmentModal> {
  final BarberDataService _dataService = BarberDataService();
  late DateTime _selectedDate;
  String? _selectedTimeSlot;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.appointment.dateTime;
    _selectedTimeSlot =
        '${widget.appointment.dateTime.hour}:${widget.appointment.dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleReschedule() {
    if (_selectedTimeSlot == null) {
      setState(() => _errorMessage = 'Please select a time slot.');
      return;
    }

    final parts = _selectedTimeSlot!.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final newDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      _dataService.rescheduleAppointment(
        widget.appointment.id,
        newDateTime,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Appointment rescheduled to ${_getMonthName(newDateTime.month)} ${newDateTime.day} at ${hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}',
          ),
          backgroundColor: AppTheme.primary,
        ),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final availableSlots = _dataService.getAvailableTimeSlots(
      _selectedDate,
      widget.appointment.durationMinutes,
    );

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.edit_calendar_rounded, color: AppTheme.primary, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Reschedule Appointment',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const Divider(color: AppTheme.borderColor, height: 20),

            // Current Service Info Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.content_cut_rounded, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.appointment.serviceName} (${widget.appointment.customerName})',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Duration: ${widget.appointment.durationMinutes} min • \$${widget.appointment.basePrice.toStringAsFixed(0)}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Date Picker Row
            const Text(
              'Select New Date',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(14, (index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
                  final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                  final dayName = dayNames[date.weekday % 7];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                          _selectedTimeSlot = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary : AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : AppTheme.borderColor,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              dayName,
                              style: TextStyle(
                                color: isSelected ? Colors.white70 : AppTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // Time Slots Selection
            const Text(
              'Select Available Time Slot',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (availableSlots.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No available time slots on this day. Please select another date.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableSlots.map((slot) {
                  final timeStr = '${slot.hour}:${slot.minute.toString().padLeft(2, '0')}';
                  final formattedLabel =
                      '${slot.hour > 12 ? slot.hour - 12 : (slot.hour == 0 ? 12 : slot.hour)}:${slot.minute.toString().padLeft(2, '0')} ${slot.hour >= 12 ? 'PM' : 'AM'}';
                  final isSelected = _selectedTimeSlot == timeStr;

                  return ChoiceChip(
                    label: Text(formattedLabel),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTimeSlot = selected ? timeStr : null;
                      });
                    },
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.background,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.5,
                    ),
                  );
                }).toList(),
              ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppTheme.error, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Confirm Reschedule Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleReschedule,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Confirm Reschedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
