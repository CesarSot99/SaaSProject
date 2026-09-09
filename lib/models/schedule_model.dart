import 'package:flutter/material.dart';

class DaySchedule {
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String dayName;
  bool isWorkingDay;
  TimeOfDay startTime;
  TimeOfDay endTime;
  bool hasBreak;
  TimeOfDay? breakStartTime;
  TimeOfDay? breakEndTime;

  DaySchedule({
    required this.dayOfWeek,
    required this.dayName,
    required this.isWorkingDay,
    required this.startTime,
    required this.endTime,
    this.hasBreak = true,
    this.breakStartTime,
    this.breakEndTime,
  });

  String get formattedStart => _formatTimeOfDay(startTime);
  String get formattedEnd => _formatTimeOfDay(endTime);
  String get formattedBreak => (hasBreak && breakStartTime != null && breakEndTime != null)
      ? '${_formatTimeOfDay(breakStartTime!)} - ${_formatTimeOfDay(breakEndTime!)}'
      : 'No Break';

  static String _formatTimeOfDay(TimeOfDay tod) {
    final hour12 = tod.hour > 12 ? tod.hour - 12 : (tod.hour == 0 ? 12 : tod.hour);
    final period = tod.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = tod.minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }
}

class VacationDateRule {
  final String id;
  final DateTime date;
  final String reason;
  final bool isDayOff;

  VacationDateRule({
    required this.id,
    required this.date,
    required this.reason,
    this.isDayOff = true,
  });
}

class ManualBlockSlot {
  final String id;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String reason;

  ManualBlockSlot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.reason,
  });

  String get formattedTime =>
      '${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}';

  static String _formatTimeOfDay(TimeOfDay tod) {
    final hour12 = tod.hour > 12 ? tod.hour - 12 : (tod.hour == 0 ? 12 : tod.hour);
    final period = tod.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = tod.minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }
}
