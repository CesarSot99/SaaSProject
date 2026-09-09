import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/barber_info_card.dart';
import '../../../widgets/change_password_modal.dart';
import '../../../widgets/edit_profile_modal.dart';
import '../../../widgets/link_barber_modal.dart';
import '../../../widgets/notification_preferences_modal.dart';
import '../../role_selection_screen.dart';

class CustomerProfileTab extends StatelessWidget {
  const CustomerProfileTab({super.key});

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
          'Are you sure you want to log out of your account?',
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

  void _openLinkBarberModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LinkBarberModal(),
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

    return ListenableBuilder(
      listenable: authService,
      builder: (context, _) {
        final customer = authService.currentUser as CustomerUser?;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            title: const Text('My Profile & Account'),
            centerTitle: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client Profile Card
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
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.tertiary.withValues(alpha: 0.2),
                          backgroundImage: customer?.avatarUrl != null && customer!.avatarUrl!.isNotEmpty
                              ? (customer.avatarUrl!.startsWith('data:image')
                                  ? MemoryImage(base64Decode(customer.avatarUrl!.split(',').last)) as ImageProvider
                                  : NetworkImage(customer.avatarUrl!))
                              : null,
                          child: customer?.avatarUrl == null || customer!.avatarUrl!.isEmpty
                              ? const Icon(Icons.person_rounded, color: AppTheme.tertiary, size: 28)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer?.fullName ?? 'John Client',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${customer?.phone ?? "+1 (555) 123-4567"} • ${customer?.email ?? "john@client.com"}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Associated Stylist / Barberia Favorita Section
                  const Text(
                    'FAVORITE BARBERSHOP / ASSOCIATED BARBER',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  BarberInfoCard(
                    barberName: customer?.assignedBarberName ?? 'Carlos Rodríguez',
                    publicCode: customer?.assignedBarberPhone ?? '+1 (555) 987-6543',
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: () => _openLinkBarberModal(context),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: const Text('Change Barber / Link New Code'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Settings & Account Options
                  const Text(
                    'ACCOUNT SETTINGS',
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
                          title: const Text('Configure Notifications & Alerts', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textSecondary),
                          onTap: () => _openNotificationPreferences(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Log Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                      label: const Text('Log Out', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
