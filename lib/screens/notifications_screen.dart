import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/notification_preferences_modal.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  String _selectedFilter = 'TODAS'; // 'TODAS', 'UNREAD', 'CITAS', 'PAGOS', 'PROMOS'

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }

  List<NotificationModel> get _filteredNotifications {
    return _service.notifications.where((n) {
      if (_selectedFilter == 'UNREAD') return !n.isRead;
      if (_selectedFilter == 'CITAS') return n.type.categoryGroup == 'citas';
      if (_selectedFilter == 'PAGOS') return n.type.categoryGroup == 'pagos';
      if (_selectedFilter == 'PROMOS') return n.type.categoryGroup == 'promos';
      return true;
    }).toList();
  }

  void _openPreferencesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationPreferencesModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredNotifications;
    final unreadTotal = _service.unreadCount;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.notifications_rounded, color: AppTheme.primary, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Notifications',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unreadTotal > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadTotal unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadTotal > 0)
            TextButton.icon(
              onPressed: () => _service.markAllAsRead(),
              icon: const Icon(Icons.done_all_rounded, size: 16, color: AppTheme.primary),
              label: const Text('Mark all as read', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppTheme.textSecondary),
            tooltip: 'Notification Preferences',
            onPressed: _openPreferencesModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('TODAS', 'All (${_service.notifications.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('UNREAD', 'Unread ($unreadTotal)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('CITAS', 'Appointments'),
                  const SizedBox(width: 8),
                  _buildFilterChip('PAGOS', 'Payments & Plan'),
                  const SizedBox(width: 8),
                  _buildFilterChip('PROMOS', 'Promos & Messages'),
                ],
              ),
            ),
          ),

          const Divider(color: AppTheme.borderColor, height: 1),

          // Notifications List
          Expanded(
            child: filteredList.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedFilter == 'UNREAD' ? Icons.mark_email_read_rounded : Icons.notifications_none_rounded,
                          color: AppTheme.textSecondary,
                          size: 56,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'UNREAD'
                              ? 'All caught up! You have no unread notifications.'
                              : 'No notifications found in this category.',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final item = filteredList[idx];
                      final type = item.type;
                      final channel = item.channel;

                      return InkWell(
                        onTap: () {
                          if (!item.isRead) {
                            _service.markAsRead(item.id);
                          }
                          // Handle optional tap feedback
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: item.isRead ? AppTheme.cardBg : AppTheme.surfaceLight.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: item.isRead ? AppTheme.borderColor : AppTheme.primary.withValues(alpha: 0.4),
                              width: item.isRead ? 1 : 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Unread Dot Indicator
                              if (!item.isRead)
                                Container(
                                  margin: const EdgeInsets.only(top: 6, right: 8),
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),

                              // Icon Badge
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: type.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(type.icon, color: type.color, size: 20),
                              ),

                              const SizedBox(width: 12),

                              // Notification Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: 14,
                                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatRelativeTime(item.timestamp),
                                          style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      item.message,
                                      style: TextStyle(
                                        color: item.isRead ? AppTheme.textSecondary : AppTheme.textPrimary,
                                        fontSize: 12.5,
                                        height: 1.3,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Channel Badge Pill & Actions Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.surface,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppTheme.borderColor),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(channel.icon, size: 12, color: AppTheme.textSecondary),
                                              const SizedBox(width: 4),
                                              Text(
                                                channel.displayName,
                                                style: const TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                item.isRead ? Icons.mark_email_unread_outlined : Icons.mark_email_read_outlined,
                                                color: AppTheme.textSecondary,
                                                size: 18,
                                              ),
                                              tooltip: item.isRead ? 'Mark as unread' : 'Mark as read',
                                              onPressed: () => _service.toggleReadState(item.id),
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.all(4),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 18),
                                              tooltip: 'Delete notification',
                                              onPressed: () => _service.deleteNotification(item.id),
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.all(4),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primary,
      backgroundColor: AppTheme.cardBg,
      side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.borderColor),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
      ),
      onSelected: (sel) {
        if (sel) {
          setState(() {
            _selectedFilter = value;
          });
        }
      },
    );
  }
}
