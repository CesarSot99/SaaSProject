import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/barber_data_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/change_password_modal.dart';
import '../../../widgets/edit_profile_modal.dart';
import '../../../widgets/notification_preferences_modal.dart';
import '../../role_selection_screen.dart';
import 'barber_reports_tab.dart';
import 'barber_schedule_tab.dart';

class BarberMoreTab extends StatelessWidget {
  const BarberMoreTab({super.key});

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderColor),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.error),
            SizedBox(width: 8),
            Text('Log Out', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your BarberSync account?',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AuthService().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _copyBarberCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Barber code "$code" copied to clipboard!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _openEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditProfileModal(),
    );
  }

  void _openChangePassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChangePasswordModal(),
    );
  }

  void _openNotificationPreferences(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationPreferencesModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final dataService = BarberDataService();
    final barber = authService.currentUser as BarberUser?;
    final plan = authService.availablePlans.firstWhere(
      (p) => p.id == barber?.planId,
      orElse: () => authService.availablePlans.first,
    );

    final barberCode = barber?.phone ?? '+1 (555) 987-6543';

    return ListenableBuilder(
      listenable: Listenable.merge([authService, dataService]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            title: const Text('Profile & Settings'),
            centerTitle: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barber Profile Summary Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                              backgroundImage: barber?.avatarUrl != null && barber!.avatarUrl!.isNotEmpty
                                  ? (barber.avatarUrl!.startsWith('data:image')
                                      ? MemoryImage(base64Decode(barber.avatarUrl!.split(',').last)) as ImageProvider
                                      : NetworkImage(barber.avatarUrl!))
                                  : null,
                              child: barber?.avatarUrl == null || barber!.avatarUrl!.isEmpty
                                  ? const Icon(Icons.content_cut_rounded, color: AppTheme.primary, size: 28)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    barber?.fullName ?? 'Carlos Rodriguez',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${barber?.shopName ?? "Elite Barber Shop"} • ${barber?.shopLocation ?? "45 Main St"}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    barber?.email ?? 'carlos@barber.com',
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Divider(color: AppTheme.borderColor, height: 24),

                        // Barber Code Banner (Share with Clients)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Unique Barber Code',
                                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    barberCode,
                                    style: const TextStyle(color: AppTheme.primary, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _copyBarberCode(context, barberCode),
                                icon: const Icon(Icons.copy_rounded, size: 14),
                                label: const Text('Copy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BARBERSHOP MANAGEMENT Section
                  const Text(
                    'BARBERSHOP MANAGEMENT',
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
                        ListTile(
                          leading: const Icon(Icons.insert_chart_rounded, color: AppTheme.tertiary),
                          title: const Text(
                            'Reports & Business Analytics',
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Client retention, appointment trends & revenue',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textSecondary),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BarberReportsTab()),
                            );
                          },
                        ),
                        const Divider(color: AppTheme.borderColor, height: 1),
                        ListTile(
                          leading: const Icon(Icons.access_time_filled_rounded, color: AppTheme.primary),
                          title: const Text(
                            'Working Hours & Schedule Settings',
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Business hours, lunch breaks & vacation days',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textSecondary),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BarberScheduleTab()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Subscription & Plan Section
                  const Text(
                    'SUBSCRIPTION & PLAN',
                    style: TextStyle(
                      color: AppTheme.tertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.tertiary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                barber?.subscriptionStatus.displayName ?? 'ACTIVE',
                                style: const TextStyle(
                                  color: AppTheme.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${plan.price.toStringAsFixed(0)} / mo',
                              style: const TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Auto-renews monthly',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Account & Preferences Options List
                  const Text(
                    'ACCOUNT & PREFERENCES',
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
                        ListTile(
                          leading: const Icon(Icons.person_outline_rounded, color: AppTheme.primary),
                          title: const Text('Edit Profile Information', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textSecondary),
                          onTap: () => _openEditProfile(context),
                        ),
                        const Divider(color: AppTheme.borderColor, height: 1),
                        ListTile(
                          leading: const Icon(Icons.lock_outline_rounded, color: AppTheme.accent),
                          title: const Text('Change Password', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textSecondary),
                          onTap: () => _openChangePassword(context),
                        ),
                        const Divider(color: AppTheme.borderColor, height: 1),
                        ListTile(
                          leading: const Icon(Icons.tune_rounded, color: AppTheme.warning),
                          title: const Text('Notification Preferences', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textSecondary),
                          onTap: () => _openNotificationPreferences(context),
                        ),
                        const Divider(color: AppTheme.borderColor, height: 1),
                        ListTile(
                          leading: const Icon(Icons.language_rounded, color: AppTheme.success),
                          title: const Text('Language & Region', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: const Text('English (US) • \$ USD', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textSecondary),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                      label: const Text('Log Out', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
