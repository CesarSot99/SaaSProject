import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/barber_data_service.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';

class CompleteServiceModal extends StatefulWidget {
  final AppointmentModel appointment;

  const CompleteServiceModal({
    super.key,
    required this.appointment,
  });

  @override
  State<CompleteServiceModal> createState() => _CompleteServiceModalState();
}

class _CompleteServiceModalState extends State<CompleteServiceModal> {
  final _formKey = GlobalKey<FormState>();
  final BarberDataService _dataService = BarberDataService();

  late TextEditingController _notesController;
  late TextEditingController _priceController;
  late TextEditingController _tipController;

  PaymentMethod _selectedPaymentMethod = PaymentMethod.card;
  final List<String> _photoUrls = [];

  // Sample stock haircut photos to add as simulation
  final List<String> _samplePhotos = const [
    'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
    'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400',
    'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400',
  ];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.appointment.serviceNotes ?? '');
    _priceController = TextEditingController(
      text: (widget.appointment.actualPriceCharged ?? widget.appointment.basePrice).toStringAsFixed(0),
    );
    _tipController = TextEditingController(
      text: (widget.appointment.tipAmount ?? 5.0).toStringAsFixed(0),
    );
    _photoUrls.addAll(widget.appointment.haircutPhotos);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _priceController.dispose();
    _tipController.dispose();
    super.dispose();
  }

  void _addSamplePhoto() {
    if (_photoUrls.length < 4) {
      setState(() {
        _photoUrls.add(_samplePhotos[_photoUrls.length % _samplePhotos.length]);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoUrls.removeAt(index);
    });
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text) ?? widget.appointment.basePrice;
    final tip = double.tryParse(_tipController.text) ?? 0.0;

    _dataService.completeService(
      appointmentId: widget.appointment.id,
      serviceNotes: _notesController.text.trim(),
      photos: _photoUrls,
      actualPriceCharged: price,
      tipAmount: tip,
      paymentMethod: _selectedPaymentMethod,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text('Service completed & revenue updated!'),
          ],
        ),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(_priceController.text) ?? widget.appointment.basePrice;
    final tip = double.tryParse(_tipController.text) ?? 0.0;
    final total = price + tip;

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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal Handle & Header
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complete Service',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Client: ${widget.appointment.customerName} (${widget.appointment.serviceName})',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
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

              // 1. Service Notes (Req #9)
              CustomTextField(
                label: 'Service & Technical Formula Notes',
                hint: 'e.g. Technical formula, shade #, or service details',
                controller: _notesController,
                prefixIcon: Icons.notes_rounded,
                textCapitalization: TextCapitalization.sentences,
                helperText: 'Saved to client history for future visits',
              ),

              const SizedBox(height: 16),

              // 2. Result Photos (Req #10)
              const Text(
                'Result Photos',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 72,
                child: Row(
                  children: [
                    // Add Photo Action Box
                    GestureDetector(
                      onTap: _addSamplePhoto,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.5),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, color: AppTheme.primary, size: 22),
                            SizedBox(height: 2),
                            Text(
                              '+ Photo',
                              style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Thumbnails list
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _photoUrls.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                margin: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    _photoUrls[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Container(
                                      color: AppTheme.surface,
                                      child: const Icon(Icons.content_cut_rounded, color: AppTheme.primary),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () => _removePhoto(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: AppTheme.error, size: 14),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Financial Inputs (Price Charged & Tip) (Req #12 & #13)
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Price Charged (\$)',
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.attach_money_rounded,
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Required';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Tip Received (\$)',
                      controller: _tipController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.volunteer_activism_rounded,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4. Payment Method Selector (Req #15)
              const Text(
                'Payment Method',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PaymentMethod.cash,
                  PaymentMethod.card,
                  PaymentMethod.transfer,
                ].map((method) {
                  final isSelected = method == _selectedPaymentMethod;
                  return ChoiceChip(
                    label: Text(method.displayName),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.5,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPaymentMethod = method;
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 5. Total Received Summary Card (Req #14)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL RECEIVED:',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: 'Complete & Save Service',
                icon: Icons.check_circle_rounded,
                onPressed: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
