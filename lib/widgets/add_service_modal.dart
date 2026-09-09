import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/barber_data_service.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';

class AddServiceModal extends StatefulWidget {
  const AddServiceModal({super.key});

  @override
  State<AddServiceModal> createState() => _AddServiceModalState();
}

class _AddServiceModalState extends State<AddServiceModal> {
  final _formKey = GlobalKey<FormState>();
  final BarberDataService _dataService = BarberDataService();
  final AuthService _authService = AuthService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController(text: '30');

  late String _selectedCategory;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    final currentUser = _authService.currentUser;
    final barberUser = currentUser is BarberUser ? currentUser : null;
    final businessType = barberUser?.businessType ?? BusinessType.barberShop;
    _categories = businessType.serviceCategories.where((c) => c != 'All').toList();
    _selectedCategory = _categories.isNotEmpty ? _categories.first : 'General';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text) ?? 0.0;
    final duration = int.tryParse(_durationController.text) ?? 30;
    final currentUser = _authService.currentUser;

    _dataService.addService(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      durationMinutes: duration,
      category: _selectedCategory,
      barberId: currentUser?.internalId,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Service added to catalog!'),
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
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                  const Text(
                    'Add New Service',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const Divider(color: AppTheme.borderColor, height: 24),

              // Category Selector
              const Text(
                'Category',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.background,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Service Name',
                hint: 'e.g. Haircut & Beard Trim',
                controller: _nameController,
                prefixIcon: Icons.content_cut_rounded,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter service name';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Description',
                hint: 'Short description of what the service includes',
                controller: _descriptionController,
                prefixIcon: Icons.description_outlined,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Price (\$)',
                      hint: '35.00',
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.attach_money_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Enter price';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Duration (min)',
                      hint: '30',
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.timer_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Enter duration';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: 'Save Service',
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
