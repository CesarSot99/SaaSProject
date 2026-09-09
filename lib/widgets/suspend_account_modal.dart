import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/barber_data_service.dart';
import '../theme/app_theme.dart';

class SuspendAccountModal extends StatefulWidget {
  final BarberUser barber;

  const SuspendAccountModal({
    super.key,
    required this.barber,
  });

  @override
  State<SuspendAccountModal> createState() => _SuspendAccountModalState();
}

class _SuspendAccountModalState extends State<SuspendAccountModal> {
  final BarberDataService _dataService = BarberDataService();
  String _selectedReason = 'Payment Non-Compliance';
  final TextEditingController _notesController = TextEditingController();

  final List<String> _reasons = [
    'Payment Non-Compliance',
    'Terms of Service Violation',
    'Fraudulent Activity',
    'Customer Abuse Complaints',
    'Temporary Maintenance Hold',
    'Other (Custom Note)',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _confirmSuspension() {
    _dataService.suspendBarberAccount(widget.barber.internalId);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account "${widget.barber.shopName}" has been suspended.'),
        backgroundColor: AppTheme.error,
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
              const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Suspend Account: ${widget.barber.shopName}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: AppTheme.borderColor, height: 20),

          const Text(
            'Suspending this account will block dashboard access and prevent client bookings immediately.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          const Text(
            'Select Suspension Reason:',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: _selectedReason,
            dropdownColor: AppTheme.surface,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
            ),
            items: _reasons.map((r) {
              return DropdownMenuItem<String>(
                value: r,
                child: Text(r),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedReason = val);
            },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _notesController,
            maxLines: 3,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Additional administrative notes (optional)...',
              hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _confirmSuspension,
              icon: const Icon(Icons.block_rounded, size: 18),
              label: const Text('Confirm Account Suspension'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
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
