import 'package:flutter/material.dart';
import '../../../models/service_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/barber_data_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class CustomerBookTab extends StatefulWidget {
  final VoidCallback? onBookingSuccess;

  const CustomerBookTab({
    super.key,
    this.onBookingSuccess,
  });

  @override
  State<CustomerBookTab> createState() => _CustomerBookTabState();
}

class _CustomerBookTabState extends State<CustomerBookTab> {
  final AuthService _authService = AuthService();
  final BarberDataService _dataService = BarberDataService();

  int _currentStep = 1;

  BarberServiceItem? _selectedService;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;
  String _selectedCategoryFilter = 'All';
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _format12Hour(DateTime dt) {
    final hour12 = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final hourStr = hour12.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }

  void _confirmBooking() {
    final customer = _authService.currentUser as CustomerUser?;
    if (_selectedService == null || _selectedTimeSlot == null) return;

    int hour = 9;
    int minute = 0;
    final isPM = _selectedTimeSlot!.contains('PM');
    final isAM = _selectedTimeSlot!.contains('AM');
    final cleanTime = _selectedTimeSlot!.replaceAll(' AM', '').replaceAll(' PM', '').trim();
    final parts = cleanTime.split(':');
    final parsedHour = int.tryParse(parts[0]) ?? 9;
    minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    if (isAM) {
      hour = parsedHour == 12 ? 0 : parsedHour;
    } else if (isPM) {
      hour = parsedHour == 12 ? 12 : parsedHour + 12;
    } else {
      hour = parsedHour;
    }

    final appointmentDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );

    try {
      _dataService.bookAppointment(
        customerId: customer?.internalId ?? 'UID-CUST-101',
        customerName: customer?.fullName ?? 'John Client',
        customerPhone: customer?.phone ?? '+1 (555) 123-4567',
        dateTime: appointmentDateTime,
        serviceName: _selectedService!.name,
 basePrice: _selectedService!.price,
        durationMinutes: _selectedService!.durationMinutes,
        customerNotes: _notesController.text.trim(),
      );

      // Reset state & show success toast
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Appointment requested! Status: PENDING (Waiting for barber confirmation)')),
            ],
          ),
          backgroundColor: AppTheme.success,
          duration: Duration(seconds: 4),
        ),
      );

      setState(() {
        _currentStep = 1;
        _selectedService = null;
        _selectedTimeSlot = null;
        _notesController.clear();
      });

      widget.onBookingSuccess?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(e.toString().replaceAll('Exception: ', ''))),
            ],
          ),
          backgroundColor: AppTheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BarberServiceItem> services = _dataService.services.where((s) => s.isActive).toList();
    if (_selectedCategoryFilter != 'All') {
      services = services.where((s) => s.category == _selectedCategoryFilter).toList();
    }
    final availableSlots = _dataService
        .getAvailableTimeSlots(_selectedDate, _selectedService?.durationMinutes ?? 30)
        .map((dt) => _format12Hour(dt))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper Progress Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: AppTheme.surface,
              child: Row(
                children: [
                  _StepIndicator(step: 1, title: 'Service', isActive: _currentStep >= 1, isCurrent: _currentStep == 1),
                  _StepLine(isActive: _currentStep >= 2),
                  _StepIndicator(step: 2, title: 'Date & Time', isActive: _currentStep >= 2, isCurrent: _currentStep == 2),
                  _StepLine(isActive: _currentStep >= 3),
                  _StepIndicator(step: 3, title: 'Confirm', isActive: _currentStep >= 3, isCurrent: _currentStep == 3),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: _buildCurrentStepView(services, availableSlots),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepView(List<BarberServiceItem> services, List<String> availableSlots) {
    if (_currentStep == 1) {
      // STEP 1: Select Service
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a Service',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose the haircut or styling service you want to reserve',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),

          // Category Filter Chips for Customer
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'All',
                'Haircut',
                'Haircut + Beard',
                'Beard',
                'Kids Haircut',
                'Line Up',
                'Design',
                'Treatments',
              ].map((cat) {
                final isSelected = cat == _selectedCategoryFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategoryFilter = cat;
                        });
                      }
                    },
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final srv = services[index];
              final isSelected = srv.id == _selectedService?.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedService = srv;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.secondary.withValues(alpha: 0.2),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isSelected ? AppTheme.primary : AppTheme.surfaceLight,
                          child: Icon(
                            Icons.content_cut_rounded,
                            color: isSelected ? const Color(0xFF070D18) : AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                srv.name,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${srv.description} (${srv.durationMinutes} min)',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${srv.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          CustomButton(
            text: 'Continue to Date & Time',
            icon: Icons.arrow_forward_rounded,
            onPressed: _selectedService == null
                ? null
                : () {
                    setState(() {
                      _currentStep = 2;
                    });
                  },
          ),
        ],
      );
    } else if (_currentStep == 2) {
      // STEP 2: Select Date & Available Time Slot
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Date & Time',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: const Text('Back to Services', style: TextStyle(color: AppTheme.primary, fontSize: 12)),
              ),
            ],
          ),
          Text(
            'Service: ${_selectedService?.name} (\$${_selectedService?.price.toStringAsFixed(0)})',
            style: const TextStyle(color: AppTheme.tertiary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Date Picker Chips
          const Text(
            'Select Date',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index + 1));
                final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;

                final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                      _selectedTimeSlot = null;
                    });
                  },
                  child: Container(
                    width: 65,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.secondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF070D18) : AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF070D18) : AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Available Time Slots Grid
          const Text(
            'Available Time Slots',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (availableSlots.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.event_busy_rounded, color: AppTheme.warning, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Barber is unavailable on this date (Day Off / Vacation / Fully Booked). Please select another date.',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: availableSlots.map((slot) {
              final isSelected = slot == _selectedTimeSlot;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimeSlot = slot;
                  });
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width - 60) / 3,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.tertiary : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.tertiary : AppTheme.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      slot,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF1E0A38) : AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          CustomTextField(
            label: 'Special Requests / Notes (Optional)',
            hint: 'e.g. Please leave top longer, scissor trim only',
            controller: _notesController,
            prefixIcon: Icons.edit_note_rounded,
          ),

          const SizedBox(height: 24),

          CustomButton(
            text: 'Review & Confirm',
            icon: Icons.arrow_forward_rounded,
            onPressed: _selectedTimeSlot == null
                ? null
                : () {
                    setState(() {
                      _currentStep = 3;
                    });
                  },
          ),
        ],
      );
    } else {
      // STEP 3: Booking Confirmation Summary (Spec #8)
      final customer = _authService.currentUser as CustomerUser?;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Booking Summary',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentStep = 2),
                child: const Text('Edit Date/Time', style: TextStyle(color: AppTheme.primary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                _SummaryRow(title: 'Barber', value: customer?.assignedBarberName ?? 'Carlos Rodríguez'),
                const Divider(color: AppTheme.borderColor, height: 20),
                _SummaryRow(title: 'Service', value: _selectedService?.name ?? ''),
                const Divider(color: AppTheme.borderColor, height: 20),
                _SummaryRow(title: 'Date', value: '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}'),
                const Divider(color: AppTheme.borderColor, height: 20),
                _SummaryRow(title: 'Time', value: _selectedTimeSlot ?? ''),
                const Divider(color: AppTheme.borderColor, height: 20),
                _SummaryRow(title: 'Duration', value: '${_selectedService?.durationMinutes} minutes'),
                const Divider(color: AppTheme.borderColor, height: 20),
                _SummaryRow(title: 'Initial Status', value: 'PENDING (Barber Approval)', valueColor: AppTheme.warning),
                const Divider(color: AppTheme.borderColor, height: 20),
                _SummaryRow(
                  title: 'Total Price',
                  value: '\$${_selectedService?.price.toStringAsFixed(2)}',
                  valueColor: AppTheme.primary,
                  isBold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          CustomButton(
            text: 'Confirm & Send Request',
            icon: Icons.check_circle_rounded,
            onPressed: _confirmBooking,
          ),
        ],
      );
    }
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  final String title;
  final bool isActive;
  final bool isCurrent;

  const _StepIndicator({
    required this.step,
    required this.title,
    required this.isActive,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? AppTheme.primary : AppTheme.surfaceLight,
          child: Text(
            '$step',
            style: TextStyle(
              color: isActive ? const Color(0xFF070D18) : AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: TextStyle(
            color: isCurrent ? AppTheme.primary : (isActive ? AppTheme.textPrimary : AppTheme.textMuted),
            fontSize: 11.5,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isActive;

  const _StepLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: isActive ? AppTheme.primary : AppTheme.secondary.withValues(alpha: 0.2),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textPrimary,
            fontSize: isBold ? 17 : 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
