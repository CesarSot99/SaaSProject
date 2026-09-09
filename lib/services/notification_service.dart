import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal() {
    _initMockNotifications();
  }

  final List<NotificationModel> _notifications = [];
  NotificationPreferencesModel _preferences = NotificationPreferencesModel();

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  NotificationPreferencesModel get preferences => _preferences;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _initMockNotifications() {
    final now = DateTime.now();

    _notifications.addAll([
      NotificationModel(
        id: 'notif_1',
        userId: 'UID-BARB-7X92K',
        title: 'New Appointment Booked!',
        message: 'John Smith has booked an appointment for Haircut today at 09:00 AM.',
        type: NotificationType.newAppointment,
        channel: NotificationChannel.push,
        timestamp: now.subtract(const Duration(minutes: 10)),
        isRead: false,
        relatedId: 'apt_101',
      ),
      NotificationModel(
        id: 'notif_2',
        userId: 'UID-BARB-7X92K',
        title: 'Pending Appointment Request',
        message: 'David Lee requested an appointment for 02:00 PM. Confirmation required.',
        type: NotificationType.pendingAppointment,
        channel: NotificationChannel.inApp,
        timestamp: now.subtract(const Duration(minutes: 35)),
        isRead: false,
        relatedId: 'apt_104',
      ),
      NotificationModel(
        id: 'notif_3',
        userId: 'UID-BARB-7X92K',
        title: '⏰ Upcoming Appointment Reminder',
        message: 'Your upcoming appointment with Robert Garcia (Haircut + Beard) starts in 15 minutes.',
        type: NotificationType.appointmentReminder,
        channel: NotificationChannel.push,
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        relatedId: 'apt_102',
      ),
      NotificationModel(
        id: 'notif_4',
        userId: 'UID-BARB-7X92K',
        title: 'Appointment Rescheduled',
        message: 'Michael Brown shifted his appointment time from 10:30 AM to 11:30 AM.',
        type: NotificationType.rescheduledAppointment,
        channel: NotificationChannel.sms,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 15)),
        isRead: true,
        relatedId: 'apt_103',
      ),
      NotificationModel(
        id: 'notif_5',
        userId: 'UID-BARB-7X92K',
        title: 'Appointment Confirmed by Client',
        message: 'Alex Turner confirmed attendance for the 04:30 PM slot.',
        type: NotificationType.confirmedAppointment,
        channel: NotificationChannel.email,
        timestamp: now.subtract(const Duration(hours: 4)),
        isRead: true,
        relatedId: 'apt_105',
      ),
      NotificationModel(
        id: 'notif_6',
        userId: 'UID-BARB-7X92K',
        title: 'Working Hours Updated',
        message: 'Your schedule settings for Friday were updated successfully.',
        type: NotificationType.scheduleChange,
        channel: NotificationChannel.inApp,
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: 'notif_7',
        userId: 'UID-BARB-7X92K',
        title: '⚠️ Subscription Payment Processed',
        message: 'Monthly payment for BarberSync Pro (\$29.99) has been charged successfully.',
        type: NotificationType.subscription,
        channel: NotificationChannel.email,
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      NotificationModel(
        id: 'notif_8',
        userId: 'UID-BARB-7X92K',
        title: 'Payment & Checkout Alert',
        message: 'Payment for appointment #apt_101 (\$30.00) completed via card.',
        type: NotificationType.paymentIssue,
        channel: NotificationChannel.inApp,
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
      NotificationModel(
        id: 'notif_9',
        userId: 'UID-BARB-7X92K',
        title: '🎉 Exclusive BarberSync Promo',
        message: '20% off all grooming supply orders for Pro members this month!',
        type: NotificationType.promotions,
        channel: NotificationChannel.push,
        timestamp: now.subtract(const Duration(days: 4)),
        isRead: true,
      ),
      NotificationModel(
        id: 'notif_10',
        userId: 'UID-BARB-7X92K',
        title: 'Support Desk Reply',
        message: 'A support agent responded to your tax report inquiry.',
        type: NotificationType.directMessage,
        channel: NotificationChannel.inApp,
        timestamp: now.subtract(const Duration(days: 5)),
        isRead: true,
      ),
      NotificationModel(
        id: 'notif_11',
        userId: 'UID-BARB-7X92K',
        title: 'Appointment Canceled by Client',
        message: 'Client Carlos Ruiz canceled his 05:00 PM appointment.',
        type: NotificationType.canceledAppointment,
        channel: NotificationChannel.sms,
        timestamp: now.subtract(const Duration(days: 6)),
        isRead: true,
      ),
    ]);
  }

  // CRUD Operations
  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
    NotificationChannel channel = NotificationChannel.inApp,
    String? relatedId,
  }) {
    final newNotif = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'UID-BARB-7X92K',
      title: title,
      message: message,
      type: type,
      channel: channel,
      timestamp: DateTime.now(),
      isRead: false,
      relatedId: relatedId,
    );
    _notifications.insert(0, newNotif);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void toggleReadState(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = !_notifications[index].isRead;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void updatePreferences(NotificationPreferencesModel newPreferences) {
    _preferences = newPreferences;
    notifyListeners();
  }
}
