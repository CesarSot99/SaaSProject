import 'package:flutter/material.dart';
import '../../../models/schedule_model.dart';
import '../../../services/barber_data_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/block_time_slot_modal.dart';

class BarberScheduleTab extends StatefulWidget {
  const BarberScheduleTab({super.key});

  @override
  State<BarberScheduleTab> createState() => _BarberScheduleTabState();
}

class _BarberScheduleTabState extends State<BarberScheduleTab> {
  final BarberDataService _dataService = BarberDataService();
  final _vacationReasonController = TextEditingController(text: 'Vacation / Day Off');
  DateTime _selectedVacationDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _dataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataChanged);
    _vacationReasonController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _editDaySchedule(DaySchedule day) async {
    TimeOfDay start = day.startTime;
    TimeOfDay end = day.endTime;
    bool isWorking = day.isWorkingDay;
    bool hasBreak = day.hasBreak;
    TimeOfDay breakStart = day.breakStartTime ?? const TimeOfDay(hour: 13, minute: 0);
    TimeOfDay breakEnd = day.breakEndTime ?? const TimeOfDay(hour: 14, minute: 0);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Edit ${day.dayName} Hours'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Working Day', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(isWorking ? 'Open for appointments' : 'Closed (Day Off)'),
                    value: isWorking,
                    activeThumbColor: AppTheme.primary,
                    onChanged: (val) => setDialogState(() => isWorking = val),
                  ),

                  if (isWorking) ...[
                    const Divider(color: AppTheme.borderColor),
                    const SizedBox(height: 8),

                    // Working Start / End
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showTimePicker(context: context, initialTime: start);
                              if (picked != null) setDialogState(() => start = picked);
                            },
                            child: Text('Start: ${_formatTimeOfDay(start)}', style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showTimePicker(context: context, initialTime: end);
                              if (picked != null) setDialogState(() => end = picked);
                            },
                            child: Text('End: ${_formatTimeOfDay(end)}', style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Lunch Break Switch
                    SwitchListTile(
                      title: const Text('Lunch / Meal Break', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text(hasBreak ? 'Break enabled' : 'No break'),
                      value: hasBreak,
                      activeThumbColor: AppTheme.primary,
                      onChanged: (val) => setDialogState(() => hasBreak = val),
                    ),

                    if (hasBreak)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await showTimePicker(context: context, initialTime: breakStart);
                                if (picked != null) setDialogState(() => breakStart = picked);
                              },
                              child: Text('Break Start: ${_formatTimeOfDay(breakStart)}', style: const TextStyle(fontSize: 11)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await showTimePicker(context: context, initialTime: breakEnd);
                                if (picked != null) setDialogState(() => breakEnd = picked);
                              },
                              child: Text('Break End: ${_formatTimeOfDay(breakEnd)}', style: const TextStyle(fontSize: 11)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  _dataService.updateDaySchedule(
                    DaySchedule(
                      dayOfWeek: day.dayOfWeek,
                      dayName: day.dayName,
                      isWorkingDay: isWorking,
                      startTime: start,
                      endTime: end,
                      hasBreak: hasBreak,
                      breakStartTime: hasBreak ? breakStart : null,
                      breakEndTime: hasBreak ? breakEnd : null,
                    ),
                  );
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                child: const Text('Save Hours'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddVacationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Vacation / Day Off'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedVacationDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 180)),
                );
                if (picked != null) {
                  setState(() => _selectedVacationDate = picked);
                }
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 16),
              label: Text('${_selectedVacationDate.month}/${_selectedVacationDate.day}/${_selectedVacationDate.year}'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vacationReasonController,
              decoration: const InputDecoration(
                labelText: 'Reason / Note',
                hintText: 'e.g. National Holiday, Personal Day',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _dataService.addVacationDate(
                _selectedVacationDate,
                _vacationReasonController.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vacation / Day off added!'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            child: const Text('Save Day Off'),
          ),
        ],
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour12 = tod.hour > 12 ? tod.hour - 12 : (tod.hour == 0 ? 12 : tod.hour);
    final period = tod.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = tod.minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }

  @override
  Widget build(BuildContext context) {
    final weekly = _dataService.weeklySchedule;
    final vacations = _dataService.vacationRules;
    final manualBlocks = _dataService.manualBlockSlots;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Schedule & Working Hours'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.access_time_filled_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Control Your Availability',
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Customize your working hours, lunch breaks, vacation days, and block time slots.',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 1. Weekly Working Hours
              const Text(
                'Weekly Working Hours',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: weekly.length,
                itemBuilder: (context, index) {
                  final day = weekly[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(
                            day.dayName,
                            style: TextStyle(
                              color: day.isWorkingDay ? AppTheme.textPrimary : AppTheme.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: day.isWorkingDay ? AppTheme.primaryLight : AppTheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              day.isWorkingDay ? 'OPEN' : 'CLOSED',
                              style: TextStyle(
                                color: day.isWorkingDay ? AppTheme.primary : AppTheme.error,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: day.isWorkingDay
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(
                                  'Hours: ${day.formattedStart} - ${day.formattedEnd}',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
                                ),
                                if (day.hasBreak)
                                  Text(
                                    'Break: ${day.formattedBreak}',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                                  ),
                              ],
                            )
                          : const Text('Day Off (No client bookings)', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 20),
                        onPressed: () => _editDaySchedule(day),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // 2. Vacations & Special Days Off
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vacations & Days Off',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _showAddVacationDialog,
                    icon: const Icon(Icons.flight_takeoff_rounded, size: 16, color: AppTheme.primary),
                    label: const Text('+ Add Vacation', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (vacations.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppTheme.textMuted, size: 18),
                      SizedBox(width: 8),
                      Text('No vacations or special days off scheduled.', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vacations.length,
                  itemBuilder: (context, index) {
                    final vac = vacations[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.event_busy_rounded, color: AppTheme.warning),
                        title: Text(
                          '${vac.date.month}/${vac.date.day}/${vac.date.year}',
                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(vac.reason, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20),
                          onPressed: () => _dataService.removeVacationDate(vac.id),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // 3. Manual Time Slot Blocks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Manual Blocked Slots',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const BlockTimeSlotModal(),
                      );
                    },
                    icon: const Icon(Icons.block_rounded, size: 16, color: AppTheme.error),
                    label: const Text('+ Block Time', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (manualBlocks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: AppTheme.success, size: 18),
                      SizedBox(width: 8),
                      Text('No manual time blocks currently active.', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: manualBlocks.length,
                  itemBuilder: (context, index) {
                    final blk = manualBlocks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.block_rounded, color: AppTheme.error),
                        title: Text(
                          '${blk.date.month}/${blk.date.day}/${blk.date.year} • ${blk.formattedTime}',
                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(blk.reason, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20),
                          onPressed: () => _dataService.removeManualBlockSlot(blk.id),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
