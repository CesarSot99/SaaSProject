import 'package:flutter/material.dart';
import '../services/barber_data_service.dart';
import '../theme/app_theme.dart';

class BroadcastAnnouncementModal extends StatefulWidget {
  const BroadcastAnnouncementModal({super.key});

  @override
  State<BroadcastAnnouncementModal> createState() => _BroadcastAnnouncementModalState();
}

class _BroadcastAnnouncementModalState extends State<BroadcastAnnouncementModal> {
  final BarberDataService _dataService = BarberDataService();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _targetAudience = 'ALL';

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and message'), backgroundColor: AppTheme.error),
      );
      return;
    }

    _dataService.broadcastAnnouncement(title, message, _targetAudience);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Global announcement broadcasted to all platform users!'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
            children: [
              const Icon(Icons.campaign_rounded, color: AppTheme.primary, size: 24),
              const SizedBox(width: 10),
              const Text(
                'Broadcast Global Announcement',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: AppTheme.borderColor, height: 20),

          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Announcement Title',
              hintText: 'e.g. System Maintenance Notice',
              labelStyle: const TextStyle(color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _messageController,
            maxLines: 3,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Announcement Message Body',
              hintText: 'Enter announcement details...',
              labelStyle: const TextStyle(color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
            ),
          ),
          const SizedBox(height: 14),

          DropdownButtonFormField<String>(
            initialValue: _targetAudience,
            dropdownColor: AppTheme.surface,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Target Audience',
              labelStyle: const TextStyle(color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
            ),
            items: const [
              DropdownMenuItem(value: 'ALL', child: Text('All Platform Users')),
              DropdownMenuItem(value: 'BARBERS', child: Text('Professionals / Barbers Only')),
              DropdownMenuItem(value: 'CUSTOMERS', child: Text('Clients Only')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _targetAudience = val);
            },
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Broadcast Announcement Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
