import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final AppointmentStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    IconData icon;

    switch (status) {
      case AppointmentStatus.pending:
        color = AppTheme.warning;
        bg = AppTheme.warning.withValues(alpha: 0.12);
        icon = Icons.schedule_rounded;
        break;
      case AppointmentStatus.confirmed:
        color = AppTheme.primary;
        bg = AppTheme.primaryLight;
        icon = Icons.check_circle_outline_rounded;
        break;
      case AppointmentStatus.inProgress:
        color = AppTheme.accent;
        bg = AppTheme.accentLight;
        icon = Icons.play_circle_outline_rounded;
        break;
      case AppointmentStatus.completed:
        color = AppTheme.success;
        bg = AppTheme.success.withValues(alpha: 0.12);
        icon = Icons.task_alt_rounded;
        break;
      case AppointmentStatus.canceled:
      case AppointmentStatus.noShow:
        color = AppTheme.error;
        bg = AppTheme.error.withValues(alpha: 0.12);
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}


