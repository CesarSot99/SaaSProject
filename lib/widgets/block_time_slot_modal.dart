import 'package:flutter/material.dart';
import '../services/barber_data_service.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';

class BlockTimeSlotModal extends StatefulWidget {
  const BlockTimeSlotModal({super.key});

  @override
  State<BlockTimeSlotModal> createState() => _BlockTimeSlotModalState();
}

class _BlockTimeSlotModalState extends State<BlockTimeSlotModal> {
  final _formKey = GlobalKey<FormState>();
  final BarberDataService _dataService = BarberDataService();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 15, minute: 0);
  final _reasonController = TextEditingController(text: 'Walk-in client / Personal time');

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    _dataService.addManualBlockSlot(
      _selectedDate,
      _startTime,
      _endTime,
      _reasonController.text.trim(),
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Time slot blocked on schedule!'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour12 = tod.hour > 12 ? tod.hour - 12 : (tod.hour == 0 ? 12 : tod.hour);
    final period = tod.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = tod.minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.block_rounded, color: AppTheme.error, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Block Time Slot',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
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

              const Divider(color: AppTheme.borderColor, height: 24),

              // Date Selection
              const Text(
                'Select Date',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.calendar_today_rounded, color: AppTheme.primary, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Time Pickers Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Time',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _selectTime(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatTimeOfDay(_startTime),
                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.access_time_rounded, color: AppTheme.primary, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'End Time',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _selectTime(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatTimeOfDay(_endTime),
                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.access_time_rounded, color: AppTheme.primary, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Reason for Blocking',
                hint: 'e.g. Walk-in client, Lunch break, Equipment repair',
                controller: _reasonController,
                prefixIcon: Icons.edit_note_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter reason';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: 'Confirm Block',
                icon: Icons.block_rounded,
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
