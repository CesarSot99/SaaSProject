import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';

class NotificationPreferencesModal extends StatefulWidget {
  const NotificationPreferencesModal({super.key});

  @override
  State<NotificationPreferencesModal> createState() => _NotificationPreferencesModalState();
}

class _NotificationPreferencesModalState extends State<NotificationPreferencesModal> {
  final NotificationService _service = NotificationService();

  late bool _pushEnabled;
  late bool _emailEnabled;
  late bool _smsEnabled;
  late bool _newAppointmentAlerts;
  late bool _reminder24h;
  late bool _reminder1h;
  late bool _paymentAlerts;
  late bool _marketingPromos;

  @override
  void initState() {
    super.initState();
    final prefs = _service.preferences;
    _pushEnabled = prefs.pushEnabled;
    _emailEnabled = prefs.emailEnabled;
    _smsEnabled = prefs.smsEnabled;
    _newAppointmentAlerts = prefs.newAppointmentAlerts;
    _reminder24h = prefs.reminder24h;
    _reminder1h = prefs.reminder1h;
    _paymentAlerts = prefs.paymentAlerts;
    _marketingPromos = prefs.marketingPromos;
  }

  void _savePreferences() {
    _service.updatePreferences(
      NotificationPreferencesModel(
        pushEnabled: _pushEnabled,
        emailEnabled: _emailEnabled,
        smsEnabled: _smsEnabled,
        newAppointmentAlerts: _newAppointmentAlerts,
        reminder24h: _reminder24h,
        reminder1h: _reminder1h,
        paymentAlerts: _paymentAlerts,
        marketingPromos: _marketingPromos,
      ),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification preferences saved!'),
        backgroundColor: AppTheme.success,
      ),
    );
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
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
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
                    Icon(Icons.tune_rounded, color: AppTheme.primary, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Notification Preferences',
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

            const Divider(color: AppTheme.borderColor, height: 24),

            // Notification Channels
            const Text(
              'NOTIFICATION CHANNELS',
              style: TextStyle(
                color: AppTheme.tertiary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.phone_android_rounded, color: AppTheme.primary),
                    title: const Text('Push Notifications', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Instant push alerts on your mobile device', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    value: _pushEnabled,
                    onChanged: (val) => setState(() => _pushEnabled = val),
                  ),
                  const Divider(color: AppTheme.borderColor, height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.email_rounded, color: AppTheme.tertiary),
                    title: const Text('Email Notifications', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Daily digests and email confirmations', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    value: _emailEnabled,
                    onChanged: (val) => setState(() => _emailEnabled = val),
                  ),
                  const Divider(color: AppTheme.borderColor, height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.sms_rounded, color: AppTheme.success),
                    title: const Text('SMS Text Messages', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Appointment reminders via SMS', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    value: _smsEnabled,
                    onChanged: (val) => setState(() => _smsEnabled = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Event Types and Reminders
            const Text(
              'APPOINTMENT ALERTS & REMINDERS',
              style: TextStyle(
                color: AppTheme.tertiary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.edit_calendar_rounded, color: AppTheme.primary),
                    title: const Text('New Bookings & Requests', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Notify when a client books or cancels an appointment', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    value: _newAppointmentAlerts,
                    onChanged: (val) => setState(() => _newAppointmentAlerts = val),
                  ),
                  const Divider(color: AppTheme.borderColor, height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.alarm_rounded, color: AppTheme.warning),
                    title: const Text('24-Hour Advance Reminder', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Automatic reminder 1 day prior to appointment', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    value: _reminder24h,
                    onChanged: (val) => setState(() => _reminder24h = val),
                  ),
                  const Divider(color: AppTheme.borderColor, height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.timer_rounded, color: AppTheme.accent),
                    title: const Text('1-Hour Advance Reminder', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Alert shortly before appointment start', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    value: _reminder1h,
                    onChanged: (val) => setState(() => _reminder1h = val),
                  ),
                  const Divider(color: AppTheme.borderColor, height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.payment_rounded, color: AppTheme.error),
                    title: const Text('Payments & Billing Alerts', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Notify completed payments or subscription renewals', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    value: _paymentAlerts,
                    onChanged: (val) => setState(() => _paymentAlerts = val),
                  ),
                  const Divider(color: AppTheme.borderColor, height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.local_offer_rounded, color: Colors.pink),
                    title: const Text('Promotions & News', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Special offers, discount coupons and updates', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    value: _marketingPromos,
                    onChanged: (val) => setState(() => _marketingPromos = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: 'Save Preferences',
              icon: Icons.save_rounded,
              onPressed: _savePreferences,
            ),
          ],
        ),
      ),
    );
  }
}
