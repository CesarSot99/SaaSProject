import 'package:flutter/material.dart';
import '../screens/notifications_screen.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class NotificationBellButton extends StatelessWidget {
  final Color? iconColor;

  const NotificationBellButton({
    super.key,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final service = NotificationService();

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final unread = service.unreadCount;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                unread > 0 ? Icons.notifications_active_rounded : Icons.notifications_outlined,
                color: iconColor ?? AppTheme.primary,
                size: 24,
              ),
              tooltip: 'Notification Center ($unread unread)',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            if (unread > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
