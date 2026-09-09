import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/barber_data_service.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';

class EditServiceModal extends StatefulWidget {
  final BarberServiceItem service;

  const EditServiceModal({
    super.key,
    required this.service,
  });

  @override
  State<EditServiceModal> createState() => _EditServiceModalState();
}

class _EditServiceModalState extends State<EditServiceModal> {
  final _formKey = GlobalKey<FormState>();
  final BarberDataService _dataService = BarberDataService();
  final AuthService _authService = AuthService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late String _selectedCategory;
  late List<String> _categories;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final currentUser = _authService.currentUser;
    final barberUser = currentUser is BarberUser ? currentUser : null;
    final businessType = barberUser?.businessType ?? BusinessType.barberShop;
    _categories = businessType.serviceCategories.where((c) => c != 'All').toList();
    if (!_categories.contains(widget.service.category)) {
      _categories.add(widget.service.category);
    }

    _nameController = TextEditingController(text: widget.service.name);
    _descriptionController = TextEditingController(text: widget.service.description);
    _priceController = TextEditingController(text: widget.service.price.toStringAsFixed(2));
    _durationController = TextEditingController(text: widget.service.durationMinutes.toString());
    _selectedCategory = widget.service.category;
    _isActive = widget.service.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text) ?? widget.service.price;
    final duration = int.tryParse(_durationController.text) ?? widget.service.durationMinutes;

    _dataService.updateService(
      id: widget.service.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      durationMinutes: duration,
      category: _selectedCategory,
      isActive: _isActive,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Service updated successfully!'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  void _onDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Service?'),
        content: Text('Are you sure you want to delete "${widget.service.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _dataService.deleteService(widget.service.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Service deleted.'),
                  backgroundColor: AppTheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
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
                    'Edit Service',
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

              // Active / Inactive Switch
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isActive ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: _isActive ? AppTheme.success : AppTheme.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isActive ? 'Active Service' : 'Inactive Service',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _isActive ? 'Visible for client bookings' : 'Hidden from client bookings',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _isActive,
                      activeThumbColor: AppTheme.primary,
                      onChanged: (val) {
                        setState(() {
                          _isActive = val;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

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

              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Save Changes',
                      icon: Icons.check_circle_rounded,
                      onPressed: _onSave,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
