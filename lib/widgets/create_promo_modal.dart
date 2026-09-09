import 'package:flutter/material.dart';
import '../services/barber_data_service.dart';
import '../theme/app_theme.dart';

class CreatePromoModal extends StatefulWidget {
  const CreatePromoModal({super.key});

  @override
  State<CreatePromoModal> createState() => _CreatePromoModalState();
}

class _CreatePromoModalState extends State<CreatePromoModal> {
  final BarberDataService _dataService = BarberDataService();
  final _codeController = TextEditingController();
  final _percentController = TextEditingController(text: '20');
  final _validDaysController = TextEditingController(text: '30');

  @override
  void dispose() {
    _codeController.dispose();
    _percentController.dispose();
    _validDaysController.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _codeController.text.trim();
    final percent = double.tryParse(_percentController.text.trim()) ?? 20.0;
    final validDays = int.tryParse(_validDaysController.text.trim()) ?? 30;

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a promo code (e.g. SUMMER50)'), backgroundColor: AppTheme.error),
      );
      return;
    }

    _dataService.addGlobalPromo(code, percent, validDays);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Global promo code "$code" created successfully!'),
        backgroundColor: AppTheme.success,
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
              const Icon(Icons.local_offer_rounded, color: AppTheme.tertiary, size: 24),
              const SizedBox(width: 10),
              const Text(
                'Create Global Promo Code',
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
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Promo Code',
              hintText: 'e.g. SUMMER50',
              labelStyle: const TextStyle(color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _percentController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Discount %',
                    hintText: '20',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _validDaysController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Validity (Days)',
                    hintText: '30',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Publish Global Promo Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.tertiary,
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
