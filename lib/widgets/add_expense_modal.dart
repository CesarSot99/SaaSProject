import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../models/finance_model.dart';
import '../services/barber_data_service.dart';
import '../theme/app_theme.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';

class AddExpenseModal extends StatefulWidget {
  final ExpenseModel? expenseToEdit;

  const AddExpenseModal({
    super.key,
    this.expenseToEdit,
  });

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  final BarberDataService _dataService = BarberDataService();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _receiptUrlController = TextEditingController();

  ExpenseCategory _selectedCategory = ExpenseCategory.products;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.card;
  DateTime _selectedDate = DateTime.now();
  String? _receiptPhotoPath;

  final List<String> _sampleReceipts = [
    'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=600',
    'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600',
    'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final exp = widget.expenseToEdit!;
      _titleController.text = exp.title;
      _amountController.text = exp.amount.toStringAsFixed(2);
      _notesController.text = exp.notes ?? '';
      _selectedCategory = exp.category;
      _selectedPaymentMethod = exp.paymentMethod;
      _selectedDate = exp.date;
      _receiptPhotoPath = exp.receiptPhoto;
      _receiptUrlController.text = exp.receiptPhoto ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _receiptUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.cardBg,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final photo = _receiptPhotoPath?.trim().isNotEmpty == true ? _receiptPhotoPath : null;

    if (widget.expenseToEdit != null) {
      _dataService.updateExpense(
        id: widget.expenseToEdit!.id,
        title: _titleController.text.trim(),
        category: _selectedCategory,
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        date: _selectedDate,
        notes: _notesController.text.trim(),
        receiptPhoto: photo,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense updated successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    } else {
      _dataService.addExpense(
        title: _titleController.text.trim(),
        category: _selectedCategory,
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        date: _selectedDate,
        notes: _notesController.text.trim(),
        receiptPhoto: photo,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense recorded successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expenseToEdit != null;

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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit_note_rounded : Icons.receipt_long_rounded,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Edit Expense' : 'Record New Expense',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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

              // Title Field
              CustomTextField(
                label: 'Expense Description / Concept',
                hint: 'e.g. Pomade & Wax inventory, Rent payment, Utility bill',
                controller: _titleController,
                prefixIcon: Icons.edit_document,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter a description';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Amount & Date row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      label: 'Amount (\$ USD)',
                      hint: '0.00',
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.attach_money_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Enter amount';
                        if (double.tryParse(value) == null) return 'Invalid amount';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category Selector
              const Text(
                'Expense Category',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExpenseCategory.values.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return ChoiceChip(
                    avatar: Icon(
                      cat.icon,
                      size: 16,
                      color: isSelected ? Colors.white : cat.color,
                    ),
                    label: Text(cat.displayName),
                    selected: isSelected,
                    selectedColor: cat.color,
                    backgroundColor: AppTheme.cardBg,
                    side: BorderSide(
                      color: isSelected ? cat.color : AppTheme.borderColor,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Payment Method Selector
              const Text(
                'Payment Method',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [PaymentMethod.card, PaymentMethod.cash, PaymentMethod.transfer, PaymentMethod.other].map((method) {
                  final isSelected = method == _selectedPaymentMethod;
                  return ChoiceChip(
                    label: Text(method.displayName),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.cardBg,
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.borderColor,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
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

              const SizedBox(height: 16),

              // Receipt Attachment Section
              const Text(
                'Receipt / Invoice Photo',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              if (_receiptPhotoPath != null && _receiptPhotoPath!.isNotEmpty) ...[
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(
                          _receiptPhotoPath!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            color: AppTheme.cardBg,
                            child: const Center(
                              child: Text('Receipt attached', style: TextStyle(color: AppTheme.textSecondary)),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _receiptPhotoPath = null;
                              _receiptUrlController.clear();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _receiptPhotoPath = _sampleReceipts[0];
                                });
                              },
                              icon: const Icon(Icons.camera_alt_outlined, size: 16),
                              label: const Text('Take Photo / Upload', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                                side: const BorderSide(color: AppTheme.primary),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Or select a demo receipt photo:',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _sampleReceipts.map((url) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _receiptPhotoPath = url;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.borderColor),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.network(url, fit: BoxFit.cover),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Additional Notes (Optional)',
                hint: 'Vendor, invoice # or reference details',
                controller: _notesController,
                prefixIcon: Icons.notes_outlined,
              ),

              const SizedBox(height: 24),

              CustomButton(
                text: isEditing ? 'Save Changes' : 'Record Expense',
                icon: isEditing ? Icons.save_rounded : Icons.add_circle_outline_rounded,
                onPressed: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
