import 'package:flutter/material.dart';

enum NotificationType {
  newAppointment,
  pendingAppointment,
  confirmedAppointment,
  canceledAppointment,
  rescheduledAppointment,
  appointmentReminder,
  scheduleChange,
  paymentIssue,
  subscription,
  promotions,
  directMessage,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.newAppointment:
        return 'New Appointment';
      case NotificationType.pendingAppointment:
        return 'Pending Appointment';
      case NotificationType.confirmedAppointment:
        return 'Appointment Confirmed';
      case NotificationType.canceledAppointment:
        return 'Appointment Canceled';
      case NotificationType.rescheduledAppointment:
        return 'Appointment Rescheduled';
      case NotificationType.appointmentReminder:
        return 'Appointment Reminder';
      case NotificationType.scheduleChange:
        return 'Schedule Change';
      case NotificationType.paymentIssue:
        return 'Payment Alert';
      case NotificationType.subscription:
        return 'Subscription & Plan';
      case NotificationType.promotions:
        return 'Promotion & Offer';
      case NotificationType.directMessage:
        return 'Direct Message';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.newAppointment:
        return Icons.edit_calendar_rounded;
      case NotificationType.pendingAppointment:
        return Icons.hourglass_top_rounded;
      case NotificationType.confirmedAppointment:
        return Icons.event_available_rounded;
      case NotificationType.canceledAppointment:
        return Icons.event_busy_rounded;
      case NotificationType.rescheduledAppointment:
        return Icons.update_rounded;
      case NotificationType.appointmentReminder:
        return Icons.alarm_rounded;
      case NotificationType.scheduleChange:
        return Icons.access_time_filled_rounded;
      case NotificationType.paymentIssue:
        return Icons.payment_rounded;
      case NotificationType.subscription:
        return Icons.card_membership_rounded;
      case NotificationType.promotions:
        return Icons.local_offer_rounded;
      case NotificationType.directMessage:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.newAppointment:
        return const Color(0xFF2563EB); // Primary Blue
      case NotificationType.pendingAppointment:
        return const Color(0xFFF59E0B); // Amber
      case NotificationType.confirmedAppointment:
        return const Color(0xFF16A34A); // Green
      case NotificationType.canceledAppointment:
        return const Color(0xFFDC2626); // Red
      case NotificationType.rescheduledAppointment:
        return const Color(0xFF0EA5E9); // Cyan/Sky
      case NotificationType.appointmentReminder:
        return const Color(0xFF7C3AED); // Purple
      case NotificationType.scheduleChange:
        return const Color(0xFF6366F1); // Indigo
      case NotificationType.paymentIssue:
        return const Color(0xFFEF4444); // Red/Warning
      case NotificationType.subscription:
        return const Color(0xFFD97706); // Gold
      case NotificationType.promotions:
        return const Color(0xFFEC4899); // Pink
      case NotificationType.directMessage:
        return const Color(0xFF14B8A6); // Teal
    }
  }

  String get categoryGroup {
    switch (this) {
      case NotificationType.newAppointment:
      case NotificationType.pendingAppointment:
      case NotificationType.confirmedAppointment:
      case NotificationType.canceledAppointment:
      case NotificationType.rescheduledAppointment:
      case NotificationType.appointmentReminder:
      case NotificationType.scheduleChange:
        return 'citas';
      case NotificationType.paymentIssue:
      case NotificationType.subscription:
        return 'pagos';
      case NotificationType.promotions:
      case NotificationType.directMessage:
        return 'promos';
    }
  }
}

enum NotificationChannel {
  inApp,
  push,
  email,
  sms,
}

extension NotificationChannelExtension on NotificationChannel {
  String get displayName {
    switch (this) {
      case NotificationChannel.inApp:
        return 'In-App';
      case NotificationChannel.push:
        return 'Push';
      case NotificationChannel.email:
        return 'Email';
      case NotificationChannel.sms:
        return 'SMS';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationChannel.inApp:
        return Icons.notifications_active_rounded;
      case NotificationChannel.push:
        return Icons.phone_android_rounded;
      case NotificationChannel.email:
        return Icons.email_rounded;
      case NotificationChannel.sms:
        return Icons.sms_rounded;
    }
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationChannel channel;
  final DateTime timestamp;
  bool isRead;
  final String? relatedId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.channel = NotificationChannel.inApp,
    required this.timestamp,
    this.isRead = false,
    this.relatedId,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    NotificationChannel? channel,
    DateTime? timestamp,
    bool? isRead,
    String? relatedId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      channel: channel ?? this.channel,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
    );
  }
}

class NotificationPreferencesModel {
  bool pushEnabled;
  bool emailEnabled;
  bool smsEnabled;
  bool newAppointmentAlerts;
  bool reminder24h;
  bool reminder1h;
  bool paymentAlerts;
  bool marketingPromos;

  NotificationPreferencesModel({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.smsEnabled = false,
    this.newAppointmentAlerts = true,
    this.reminder24h = true,
    this.reminder1h = true,
    this.paymentAlerts = true,
    this.marketingPromos = false,
  });
}
