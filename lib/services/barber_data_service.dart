import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../models/finance_model.dart';
import '../models/schedule_model.dart';
import '../models/service_model.dart';
import '../models/tax_model.dart';
import '../models/user_model.dart';

class BarberDataService extends ChangeNotifier {
  static final BarberDataService _instance = BarberDataService._internal();
  factory BarberDataService() => _instance;
  BarberDataService._internal() {
    _initMockData();
  }

  final List<AppointmentModel> _appointments = [];
  final List<ExpenseModel> _expenses = [];
  final List<BarberServiceItem> _services = [];

  // Module 7 Schedule & Availability State
  final List<DaySchedule> _weeklySchedule = [
    DaySchedule(
      dayOfWeek: 1,
      dayName: 'Monday',
      isWorkingDay: true,
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 19, minute: 0),
      hasBreak: true,
      breakStartTime: const TimeOfDay(hour: 13, minute: 0),
      breakEndTime: const TimeOfDay(hour: 14, minute: 0),
    ),
    DaySchedule(
      dayOfWeek: 2,
      dayName: 'Tuesday',
      isWorkingDay: true,
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 19, minute: 0),
      hasBreak: true,
      breakStartTime: const TimeOfDay(hour: 13, minute: 0),
      breakEndTime: const TimeOfDay(hour: 14, minute: 0),
    ),
    DaySchedule(
      dayOfWeek: 3,
      dayName: 'Wednesday',
      isWorkingDay: true,
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 19, minute: 0),
      hasBreak: true,
      breakStartTime: const TimeOfDay(hour: 13, minute: 0),
      breakEndTime: const TimeOfDay(hour: 14, minute: 0),
    ),
    DaySchedule(
      dayOfWeek: 4,
      dayName: 'Thursday',
      isWorkingDay: true,
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 19, minute: 0),
      hasBreak: true,
      breakStartTime: const TimeOfDay(hour: 13, minute: 0),
      breakEndTime: const TimeOfDay(hour: 14, minute: 0),
    ),
    DaySchedule(
      dayOfWeek: 5,
      dayName: 'Friday',
      isWorkingDay: true,
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 19, minute: 0),
      hasBreak: true,
      breakStartTime: const TimeOfDay(hour: 13, minute: 0),
      breakEndTime: const TimeOfDay(hour: 14, minute: 0),
    ),
    DaySchedule(
      dayOfWeek: 6,
      dayName: 'Saturday',
      isWorkingDay: true,
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 17, minute: 0),
      hasBreak: false,
    ),
    DaySchedule(
      dayOfWeek: 7,
      dayName: 'Sunday',
      isWorkingDay: false,
      startTime: const TimeOfDay(hour: 10, minute: 0),
      endTime: const TimeOfDay(hour: 15, minute: 0),
      hasBreak: false,
    ),
  ];

  final List<VacationDateRule> _vacationRules = [];
  final List<ManualBlockSlot> _manualBlockSlots = [];

  // Module — Super Admin SaaS State
  final List<BarberUser> _allBarberUsers = [];
  final List<CustomerUser> _allCustomerUsers = [];
  final List<SaaSGlobalPromo> _globalPromos = [];
  final List<SaaSAnnouncement> _globalAnnouncements = [];

  List<BarberUser> get allBarberUsers => List.unmodifiable(_allBarberUsers);
  List<CustomerUser> get allCustomerUsers => List.unmodifiable(_allCustomerUsers);
  List<SaaSGlobalPromo> get globalPromos => List.unmodifiable(_globalPromos);
  List<SaaSAnnouncement> get globalAnnouncements => List.unmodifiable(_globalAnnouncements);

  List<DaySchedule> get weeklySchedule => List.unmodifiable(_weeklySchedule);
  List<VacationDateRule> get vacationRules => List.unmodifiable(_vacationRules);
  List<ManualBlockSlot> get manualBlockSlots => List.unmodifiable(_manualBlockSlots);

  List<AppointmentModel> get appointments => List.unmodifiable(_appointments);
  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);
  List<BarberServiceItem> get services => List.unmodifiable(_services);

  void _initMockData() {
    const barberId = 'UID-BARB-7X92K';
    final now = DateTime.now();

    // Initial Super Admin Barbers Directory
    _allBarberUsers.addAll([
      BarberUser(
        internalId: 'UID-BARB-7X92K',
        firstName: 'Carlos',
        lastName: 'Rodriguez',
        email: 'carlos@barber.com',
        phone: '+1 (555) 987-6543',
        shopName: 'Elite Barber Shop',
        shopLocation: '45 Main St, Suite 102',
        planId: 'plan_pro',
        subscriptionStatus: SubscriptionStatus.active,
        createdAt: now.subtract(const Duration(days: 90)),
        nextBillingDate: now.add(const Duration(days: 15)),
        businessType: BusinessType.barberShop,
      ),
      BarberUser(
        internalId: 'UID-BARB-8812M',
        firstName: 'Elena',
        lastName: 'Vasquez',
        email: 'elena@glamour.com',
        phone: '+1 (555) 444-9900',
        shopName: 'Glamour Hair & Beauty Salon',
        shopLocation: '120 Fashion Blvd',
        planId: 'plan_pro',
        subscriptionStatus: SubscriptionStatus.active,
        createdAt: now.subtract(const Duration(days: 45)),
        nextBillingDate: now.add(const Duration(days: 8)),
        businessType: BusinessType.hairSalon,
      ),
      BarberUser(
        internalId: 'UID-BARB-3341P',
        firstName: 'Marcus',
        lastName: 'Sterling',
        email: 'marcus@luxenails.com',
        phone: '+1 (555) 333-1122',
        shopName: 'Luxe Nail Studio & Spa',
        shopLocation: '88 Beauty Way',
        planId: 'plan_starter',
        subscriptionStatus: SubscriptionStatus.pendingPayment,
        createdAt: now.subtract(const Duration(days: 30)),
        nextBillingDate: now.subtract(const Duration(days: 2)),
        businessType: BusinessType.nailStudio,
      ),
      BarberUser(
        internalId: 'UID-BARB-9923K',
        firstName: 'Sophia',
        lastName: 'Chen',
        email: 'sophia@velvetlash.com',
        phone: '+1 (555) 777-4411',
        shopName: 'Velvet Lash & Brow Studio',
        shopLocation: '15 Studio Ave',
        planId: 'plan_enterprise',
        subscriptionStatus: SubscriptionStatus.suspended,
        createdAt: now.subtract(const Duration(days: 120)),
        nextBillingDate: now.subtract(const Duration(days: 5)),
        businessType: BusinessType.lashAndBrow,
      ),
    ]);

    // Initial Super Admin Customers Directory
    _allCustomerUsers.addAll([
      CustomerUser(
        internalId: 'UID-CUST-101',
        firstName: 'John',
        lastName: 'Smith',
        email: 'john@gmail.com',
        phone: '+1 (555) 987-6543',
        associatedBarberPhone: '+1 (555) 987-6543',
        associatedBarberId: 'UID-BARB-7X92K',
      ),
      CustomerUser(
        internalId: 'UID-CUST-102',
        firstName: 'Robert',
        lastName: 'Garcia',
        email: 'robert@yahoo.com',
        phone: '+1 (555) 444-1234',
        associatedBarberPhone: '+1 (555) 987-6543',
        associatedBarberId: 'UID-BARB-7X92K',
      ),
      CustomerUser(
        internalId: 'UID-CUST-103',
        firstName: 'Michael',
        lastName: 'Brown',
        email: 'michael@outlook.com',
        phone: '+1 (555) 333-8899',
        associatedBarberPhone: '+1 (555) 444-9900',
        associatedBarberId: 'UID-BARB-8812M',
      ),
    ]);

    // Global Promos
    _globalPromos.addAll([
      SaaSGlobalPromo(
        id: 'p_1',
        code: 'SUMMER50',
        discountPercent: 50.0,
        expiresAt: now.add(const Duration(days: 30)),
        timesUsed: 14,
      ),
      SaaSGlobalPromo(
        id: 'p_2',
        code: 'WELCOME20',
        discountPercent: 20.0,
        expiresAt: now.add(const Duration(days: 60)),
        timesUsed: 28,
      ),
    ]);

    // Global Announcements
    _globalAnnouncements.addAll([
      SaaSAnnouncement(
        id: 'ann_1',
        title: 'Platform Maintenance Notice',
        message: 'System upgrade scheduled for Sunday at 2:00 AM EST. Minimal downtime expected.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    // Default Services Catalog per Provider & Business Type
    _services.addAll(getDefaultServicesForBusinessType(BusinessType.barberShop, barberId));
    _services.addAll(getDefaultServicesForBusinessType(BusinessType.hairSalon, 'UID-BARB-8812M'));
    _services.addAll(getDefaultServicesForBusinessType(BusinessType.nailStudio, 'UID-BARB-3341P'));
    _services.addAll(getDefaultServicesForBusinessType(BusinessType.lashAndBrow, 'UID-BARB-9923K'));

    // Initial Mock Appointments
    _appointments.addAll([
      // Completed appointment Today
      AppointmentModel(
        id: 'apt_101',
        barberInternalId: barberId,
        customerId: 'UID-CUST-101',
        customerName: 'John Smith',
        customerPhone: '+1 (555) 987-6543',
        dateTime: DateTime(now.year, now.month, now.day, 9, 0),
        durationMinutes: 30,
        serviceName: 'Haircut',
        basePrice: 30.0,
        customerNotes: 'Prefers scissors on top',
        status: AppointmentStatus.completed,
        serviceNotes: 'Low skin fade, #2 on sides, leave 2 inches on top.',
        haircutPhotos: [
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
        ],
        actualPriceCharged: 30.0,
        tipAmount: 5.0,
        paymentMethod: PaymentMethod.card,
      ),

      // In Progress appointment
      AppointmentModel(
        id: 'apt_102',
        barberInternalId: barberId,
        customerId: 'UID-CUST-102',
        customerName: 'Robert Garcia',
        customerPhone: '+1 (555) 444-1234',
        dateTime: DateTime(now.year, now.month, now.day, 10, 0),
        durationMinutes: 45,
        serviceName: 'Haircut + Beard',
        basePrice: 45.0,
        customerNotes: 'First time visiting, wants a sharp razor lineup',
        status: AppointmentStatus.inProgress,
      ),

      // Confirmed appointment
      AppointmentModel(
        id: 'apt_103',
        barberInternalId: barberId,
        customerId: 'UID-CUST-103',
        customerName: 'Michael Brown',
        customerPhone: '+1 (555) 333-8899',
        dateTime: DateTime(now.year, now.month, now.day, 11, 30),
        durationMinutes: 30,
        serviceName: 'Beard Trim & Shape',
        basePrice: 20.0,
        status: AppointmentStatus.confirmed,
      ),

      // Pending appointment
      AppointmentModel(
        id: 'apt_104',
        barberInternalId: barberId,
        customerId: 'UID-CUST-104',
        customerName: 'David Lee',
        customerPhone: '+1 (555) 777-2211',
        dateTime: DateTime(now.year, now.month, now.day, 14, 0),
        durationMinutes: 30,
        serviceName: 'Haircut',
        basePrice: 30.0,
        status: AppointmentStatus.pending,
      ),

      // Historical Appointments (Past days/weeks for analytics reports)
      AppointmentModel(
        id: 'apt_201',
        barberInternalId: barberId,
        customerId: 'UID-CUST-101',
        customerName: 'John Smith',
        customerPhone: '+1 (555) 987-6543',
        dateTime: now.subtract(const Duration(days: 2, hours: 3)),
        durationMinutes: 45,
        serviceName: 'Haircut + Beard',
        basePrice: 45.0,
        status: AppointmentStatus.completed,
        actualPriceCharged: 45.0,
        tipAmount: 8.0,
        paymentMethod: PaymentMethod.card,
      ),
      AppointmentModel(
        id: 'apt_202',
        barberInternalId: barberId,
        customerId: 'UID-CUST-106',
        customerName: 'Carlos Mendoza',
        customerPhone: '+1 (555) 222-9988',
        dateTime: now.subtract(const Duration(days: 3, hours: 1)),
        durationMinutes: 30,
        serviceName: 'Haircut',
        basePrice: 30.0,
        status: AppointmentStatus.completed,
        actualPriceCharged: 30.0,
        tipAmount: 6.0,
        paymentMethod: PaymentMethod.cash,
      ),
      AppointmentModel(
        id: 'apt_203',
        barberInternalId: barberId,
        customerId: 'UID-CUST-107',
        customerName: 'James Wilson',
        customerPhone: '+1 (555) 111-5544',
        dateTime: now.subtract(const Duration(days: 4, hours: 2)),
        durationMinutes: 30,
        serviceName: 'Line Up / Touch Up',
        basePrice: 15.0,
        status: AppointmentStatus.canceled,
      ),
      AppointmentModel(
        id: 'apt_204',
        barberInternalId: barberId,
        customerId: 'UID-CUST-108',
        customerName: 'Anthony Davis',
        customerPhone: '+1 (555) 888-3322',
        dateTime: now.subtract(const Duration(days: 5, hours: 4)),
        durationMinutes: 30,
        serviceName: 'Haircut',
        basePrice: 30.0,
        status: AppointmentStatus.noShow,
      ),
      AppointmentModel(
        id: 'apt_205',
        barberInternalId: barberId,
        customerId: 'UID-CUST-109',
        customerName: 'Marcus Vance',
        customerPhone: '+1 (555) 999-0011',
        dateTime: now.subtract(const Duration(days: 6, hours: 2)),
        durationMinutes: 45,
        serviceName: 'Haircut + Beard',
        basePrice: 45.0,
        status: AppointmentStatus.completed,
        actualPriceCharged: 45.0,
        tipAmount: 10.0,
        paymentMethod: PaymentMethod.card,
      ),
      AppointmentModel(
        id: 'apt_206',
        barberInternalId: barberId,
        customerId: 'UID-CUST-110',
        customerName: 'Gabriel Santos',
        customerPhone: '+1 (555) 777-6655',
        dateTime: now.subtract(const Duration(days: 12, hours: 3)),
        durationMinutes: 30,
        serviceName: 'Kids Haircut',
        basePrice: 22.0,
        status: AppointmentStatus.completed,
        actualPriceCharged: 22.0,
        tipAmount: 3.0,
        paymentMethod: PaymentMethod.cash,
      ),
    ]);

    // Initial Mock Expenses
    _expenses.addAll([
      ExpenseModel(
        id: 'exp_1',
        barberInternalId: barberId,
        title: 'Wahl & BaByliss Clipper Maintenance',
        category: ExpenseCategory.maintenance,
        amount: 45.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        paymentMethod: PaymentMethod.card,
        notes: 'Blade sharpening and professional disinfection',
        receiptPhoto: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=600',
      ),
      ExpenseModel(
        id: 'exp_2',
        barberInternalId: barberId,
        title: 'Bulk Order Baor Hair Wax, Pomades & Gel',
        category: ExpenseCategory.products,
        amount: 120.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
        paymentMethod: PaymentMethod.card,
        notes: 'Wholesale distributor order with 15% discount',
        receiptPhoto: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600',
      ),
      ExpenseModel(
        id: 'exp_3',
        barberInternalId: barberId,
        title: 'Bi-Weekly Chair Rent Payment',
        category: ExpenseCategory.rent,
        amount: 250.0,
        date: DateTime.now().subtract(const Duration(days: 3)),
        paymentMethod: PaymentMethod.transfer,
        notes: 'Bank transfer to shop owner',
        receiptPhoto: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600',
      ),
      ExpenseModel(
        id: 'exp_4',
        barberInternalId: barberId,
        title: 'Electric & Utility Power Bill',
        category: ExpenseCategory.utilities,
        amount: 65.0,
        date: DateTime.now().subtract(const Duration(days: 5)),
        paymentMethod: PaymentMethod.card,
        notes: 'Monthly shop utility bill',
      ),
      ExpenseModel(
        id: 'exp_5',
        barberInternalId: barberId,
        title: 'Instagram & Facebook Ads Campaign',
        category: ExpenseCategory.marketing,
        amount: 80.0,
        date: DateTime.now().subtract(const Duration(days: 7)),
        paymentMethod: PaymentMethod.card,
        notes: 'New client promo campaign for haircut + beard',
      ),
      ExpenseModel(
        id: 'exp_6',
        barberInternalId: barberId,
        title: 'Towels, Rubbing Alcohol & Sanitizing Kits',
        category: ExpenseCategory.cleaning,
        amount: 35.0,
        date: DateTime.now().subtract(const Duration(days: 10)),
        paymentMethod: PaymentMethod.cash,
        notes: 'Station sanitary supplies',
      ),
    ]);
  }

  static List<BarberServiceItem> getDefaultServicesForBusinessType(BusinessType type, String providerId) {
    switch (type) {
      case BusinessType.hairSalon:
        return [
          BarberServiceItem(
            id: 'srv_hs_1_$providerId',
            barberInternalId: providerId,
            name: 'Haircut & Blowdry',
            description: 'Custom wash, cut, and professional blowdry styling',
            price: 45.0,
            durationMinutes: 45,
            category: 'Haircut & Style',
          ),
          BarberServiceItem(
            id: 'srv_hs_2_$providerId',
            barberInternalId: providerId,
            name: 'Hair Coloring / Balayage',
            description: 'Full color transformation, highlights or balayage gloss',
            price: 95.0,
            durationMinutes: 90,
            category: 'Coloring',
          ),
          BarberServiceItem(
            id: 'srv_hs_3_$providerId',
            barberInternalId: providerId,
            name: 'Keratin Smoothing Treatment',
            description: 'Deep anti-frizz smoothing keratin repair treatment',
            price: 120.0,
            durationMinutes: 90,
            category: 'Treatments',
          ),
          BarberServiceItem(
            id: 'srv_hs_4_$providerId',
            barberInternalId: providerId,
            name: 'Wash & Style',
            description: 'Shampoo, deep conditioning, and blowout or curl styling',
            price: 35.0,
            durationMinutes: 35,
            category: 'Styling',
          ),
        ];
      case BusinessType.nailStudio:
        return [
          BarberServiceItem(
            id: 'srv_ns_1_$providerId',
            barberInternalId: providerId,
            name: 'Gel Manicure',
            description: 'Nail shaping, cuticle care, gel polish and hand massage',
            price: 35.0,
            durationMinutes: 40,
            category: 'Manicure',
          ),
          BarberServiceItem(
            id: 'srv_ns_2_$providerId',
            barberInternalId: providerId,
            name: 'Spa Pedicure',
            description: 'Foot soak, scrub, nail shaping, gel polish & massage',
            price: 45.0,
            durationMinutes: 50,
            category: 'Pedicure',
          ),
          BarberServiceItem(
            id: 'srv_ns_3_$providerId',
            barberInternalId: providerId,
            name: 'Acrylic Full Set',
            description: 'Full set acrylic extension with choice of gel color',
            price: 60.0,
            durationMinutes: 60,
            category: 'Acrylic & Gel',
          ),
          BarberServiceItem(
            id: 'srv_ns_4_$providerId',
            barberInternalId: providerId,
            name: 'Nail Art Design',
            description: 'Custom hand-painted nail designs (per set)',
            price: 20.0,
            durationMinutes: 20,
            category: 'Nail Art',
          ),
        ];
      case BusinessType.lashAndBrow:
        return [
          BarberServiceItem(
            id: 'srv_lb_1_$providerId',
            barberInternalId: providerId,
            name: 'Classic Lash Extensions',
            description: 'Natural 1:1 classic lash extension full set',
            price: 75.0,
            durationMinutes: 75,
            category: 'Lash Extensions',
          ),
          BarberServiceItem(
            id: 'srv_lb_2_$providerId',
            barberInternalId: providerId,
            name: 'Volume Lash Set',
            description: 'Full fluffy volume 3D-5D eyelash extension set',
            price: 110.0,
            durationMinutes: 90,
            category: 'Lash Extensions',
          ),
          BarberServiceItem(
            id: 'srv_lb_3_$providerId',
            barberInternalId: providerId,
            name: 'Brow Lamination & Tint',
            description: 'Brow reshaping, lamination, and custom tinting',
            price: 50.0,
            durationMinutes: 45,
            category: 'Brow Shaping & Tint',
          ),
        ];
      case BusinessType.esthetician:
        return [
          BarberServiceItem(
            id: 'srv_es_1_$providerId',
            barberInternalId: providerId,
            name: 'Signature Glow Facial',
            description: 'Deep cleansing, exfoliation, hydration mask & face massage',
            price: 85.0,
            durationMinutes: 60,
            category: 'Facials',
          ),
          BarberServiceItem(
            id: 'srv_es_2_$providerId',
            barberInternalId: providerId,
            name: 'Microdermabrasion',
            description: 'Advanced skin resurfacing & renewal treatment',
            price: 110.0,
            durationMinutes: 45,
            category: 'Skin Resurfacing',
          ),
        ];
      case BusinessType.barberShop:
        return [
          BarberServiceItem(
            id: 'srv_1_$providerId',
            barberInternalId: providerId,
            name: 'Haircut',
            description: 'Classic or modern haircut with hot towel finish',
            price: 30.0,
            durationMinutes: 30,
            category: 'Haircut',
          ),
          BarberServiceItem(
            id: 'srv_2_$providerId',
            barberInternalId: providerId,
            name: 'Haircut + Beard',
            description: 'Full signature haircut and beard sculpt with razor line',
            price: 45.0,
            durationMinutes: 45,
            category: 'Haircut + Beard',
          ),
          BarberServiceItem(
            id: 'srv_3_$providerId',
            barberInternalId: providerId,
            name: 'Beard Trim & Shape',
            description: 'Beard trim, oil treatment and razor shaping',
            price: 20.0,
            durationMinutes: 20,
            category: 'Beard',
          ),
          BarberServiceItem(
            id: 'srv_4_$providerId',
            barberInternalId: providerId,
            name: 'Kids Haircut',
            description: 'Gentle haircut for children under 12',
            price: 22.0,
            durationMinutes: 25,
            category: 'Kids Haircut',
          ),
          BarberServiceItem(
            id: 'srv_5_$providerId',
            barberInternalId: providerId,
            name: 'Line Up / Touch Up',
            description: 'Outline lineup around neck, ears and forehead',
            price: 15.0,
            durationMinutes: 15,
            category: 'Line Up',
          ),
        ];
    }
  }

  // Appointment Queries
  List<AppointmentModel> getAppointmentsForDate(DateTime date) {
    return _appointments.where((a) {
      return a.dateTime.year == date.year &&
          a.dateTime.month == date.month &&
          a.dateTime.day == date.day;
    }).toList();
  }

  AppointmentModel? get nextUpcomingAppointment {
    final now = DateTime.now();
    final upcoming = _appointments
        .where((a) => a.dateTime.isAfter(now) && a.status != AppointmentStatus.canceled)
        .toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcoming.first;
  }

  List<AppointmentModel> get pendingAppointments {
    return _appointments.where((a) => a.status == AppointmentStatus.pending).toList();
  }

  List<AppointmentModel> get completedAppointments {
    return _appointments.where((a) => a.status == AppointmentStatus.completed).toList();
  }

  // Schedule & Availability Queries
  bool isDayOffOrVacation(DateTime date) {
    if (_vacationRules.any((v) =>
        v.date.year == date.year &&
        v.date.month == date.month &&
        v.date.day == date.day &&
        v.isDayOff)) {
      return true;
    }

    final dayOfWeek = date.weekday;
    final dayConfig = _weeklySchedule.firstWhere(
      (s) => s.dayOfWeek == dayOfWeek,
      orElse: () => DaySchedule(
        dayOfWeek: dayOfWeek,
        dayName: '',
        isWorkingDay: true,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
      ),
    );

    return !dayConfig.isWorkingDay;
  }

  List<DateTime> getAvailableTimeSlots(
    DateTime date,
    int serviceDurationMinutes, {
    int bufferMinutes = 5,
  }) {
    if (isDayOffOrVacation(date)) {
      return [];
    }

    final dayOfWeek = date.weekday;
    final dayConfig = _weeklySchedule.firstWhere(
      (s) => s.dayOfWeek == dayOfWeek,
      orElse: () => DaySchedule(
        dayOfWeek: dayOfWeek,
        dayName: '',
        isWorkingDay: true,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
      ),
    );

    final List<DateTime> availableSlots = [];
    final totalRequiredMinutes = serviceDurationMinutes + bufferMinutes;

    final startHour = DateTime(
      date.year,
      date.month,
      date.day,
      dayConfig.startTime.hour,
      dayConfig.startTime.minute,
    );
    final endHour = DateTime(
      date.year,
      date.month,
      date.day,
      dayConfig.endTime.hour,
      dayConfig.endTime.minute,
    );

    DateTime? breakStart;
    DateTime? breakEnd;

    if (dayConfig.hasBreak && dayConfig.breakStartTime != null && dayConfig.breakEndTime != null) {
      breakStart = DateTime(
        date.year,
        date.month,
        date.day,
        dayConfig.breakStartTime!.hour,
        dayConfig.breakStartTime!.minute,
      );
      breakEnd = DateTime(
        date.year,
        date.month,
        date.day,
        dayConfig.breakEndTime!.hour,
        dayConfig.breakEndTime!.minute,
      );
    }

    DateTime currentSlot = startHour;
    final now = DateTime.now();

    while (currentSlot.isBefore(endHour)) {
      final slotEnd = currentSlot.add(Duration(minutes: totalRequiredMinutes));

      if (currentSlot.isAfter(now)) {
        // 1. Check if slot falls in lunch break
        bool isBreakConflict = false;
        if (breakStart != null && breakEnd != null) {
          if (currentSlot.isBefore(breakEnd) && slotEnd.isAfter(breakStart)) {
            isBreakConflict = true;
          }
        }

        // 2. Check if slot falls in manual block slot
        bool isManualBlockConflict = _manualBlockSlots.any((block) {
          if (block.date.year != date.year ||
              block.date.month != date.month ||
              block.date.day != date.day) {
            return false;
          }
          final bStart = DateTime(
            date.year,
            date.month,
            date.day,
            block.startTime.hour,
            block.startTime.minute,
          );
          final bEnd = DateTime(
            date.year,
            date.month,
            date.day,
            block.endTime.hour,
            block.endTime.minute,
          );
          return currentSlot.isBefore(bEnd) && slotEnd.isAfter(bStart);
        });

        // 3. Check if slot conflicts with existing active appointments
        bool isAppointmentConflict = _appointments.any((apt) {
          if (apt.status == AppointmentStatus.canceled || apt.status == AppointmentStatus.noShow) {
            return false;
          }
          if (apt.dateTime.year != date.year ||
              apt.dateTime.month != date.month ||
              apt.dateTime.day != date.day) {
            return false;
          }
          final aptEnd = apt.dateTime.add(Duration(minutes: apt.durationMinutes));
          return currentSlot.isBefore(aptEnd) && slotEnd.isAfter(apt.dateTime);
        });

        if (!isBreakConflict && !isManualBlockConflict && !isAppointmentConflict) {
          availableSlots.add(currentSlot);
        }
      }

      currentSlot = currentSlot.add(const Duration(minutes: 30));
    }

    return availableSlots;
  }

  // Schedule CRUD Methods
  void updateDaySchedule(DaySchedule newSchedule) {
    final index = _weeklySchedule.indexWhere((s) => s.dayOfWeek == newSchedule.dayOfWeek);
    if (index != -1) {
      _weeklySchedule[index] = newSchedule;
      notifyListeners();
    }
  }

  void addVacationDate(DateTime date, String reason) {
    final rule = VacationDateRule(
      id: 'vac_${DateTime.now().millisecondsSinceEpoch}',
      date: date,
      reason: reason,
      isDayOff: true,
    );
    _vacationRules.add(rule);
    notifyListeners();
  }

  void removeVacationDate(String id) {
    _vacationRules.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  void addManualBlockSlot(DateTime date, TimeOfDay start, TimeOfDay end, String reason) {
    final block = ManualBlockSlot(
      id: 'blk_${DateTime.now().millisecondsSinceEpoch}',
      date: date,
      startTime: start,
      endTime: end,
      reason: reason,
    );
    _manualBlockSlots.add(block);
    notifyListeners();
  }

  void removeManualBlockSlot(String id) {
    _manualBlockSlots.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  // Availability & Schedule Conflict Detection
  bool checkSlotAvailability(
    String barberId,
    DateTime start,
    int durationMinutes, {
    String? excludeAppointmentId,
  }) {
    return findConflictingAppointment(
          barberId,
          start,
          durationMinutes,
          excludeAppointmentId: excludeAppointmentId,
        ) ==
        null;
  }

  AppointmentModel? findConflictingAppointment(
    String barberId,
    DateTime start,
    int durationMinutes, {
    String? excludeAppointmentId,
  }) {
    try {
      return _appointments.firstWhere((apt) {
        if (apt.id == excludeAppointmentId) return false;
        if (apt.barberInternalId != barberId) return false;
        if (apt.status == AppointmentStatus.canceled || apt.status == AppointmentStatus.noShow) {
          return false;
        }
        return apt.isOverlappingWith(start, durationMinutes);
      });
    } catch (_) {
      return null;
    }
  }

  AppointmentModel bookAppointment({
    String barberInternalId = 'UID-BARB-7X92K',
    required String customerId,
    required String customerName,
    required String customerPhone,
    required DateTime dateTime,
    required String serviceName,
    required double basePrice,
    required int durationMinutes,
    String? customerNotes,
  }) {
    final conflicting = findConflictingAppointment(
      barberInternalId,
      dateTime,
      durationMinutes,
    );
    if (conflicting != null) {
      throw Exception(
        'Time slot conflict! Barber is already booked with ${conflicting.customerName} at ${conflicting.dateTime.hour}:${conflicting.dateTime.minute.toString().padLeft(2, '0')}. Please choose another time.',
      );
    }

    final newAppointment = AppointmentModel(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      barberInternalId: barberInternalId,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      dateTime: dateTime,
      durationMinutes: durationMinutes,
      serviceName: serviceName,
      basePrice: basePrice,
      customerNotes: customerNotes,
      status: AppointmentStatus.pending,
    );

    _appointments.add(newAppointment);
    notifyListeners();
    return newAppointment;
  }

  bool rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime,
  ) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return false;

    final apt = _appointments[index];
    final conflicting = findConflictingAppointment(
      apt.barberInternalId,
      newDateTime,
      apt.durationMinutes,
      excludeAppointmentId: appointmentId,
    );

    if (conflicting != null) {
      throw Exception(
        'Time slot conflict! Barber is already booked with ${conflicting.customerName} at ${conflicting.dateTime.hour}:${conflicting.dateTime.minute.toString().padLeft(2, '0')}.',
      );
    }

    _appointments[index] = AppointmentModel(
      id: apt.id,
      barberInternalId: apt.barberInternalId,
      customerId: apt.customerId,
      customerName: apt.customerName,
      customerPhone: apt.customerPhone,
      customerPhoto: apt.customerPhoto,
      dateTime: newDateTime,
      durationMinutes: apt.durationMinutes,
      serviceName: apt.serviceName,
      basePrice: apt.basePrice,
      customerNotes: apt.customerNotes,
      status: apt.status == AppointmentStatus.pending ? AppointmentStatus.pending : AppointmentStatus.confirmed,
      serviceNotes: apt.serviceNotes,
      haircutPhotos: apt.haircutPhotos,
      actualPriceCharged: apt.actualPriceCharged,
      tipAmount: apt.tipAmount,
      paymentMethod: apt.paymentMethod,
      cancelReason: apt.cancelReason,
    );

    notifyListeners();
    return true;
  }

  void cancelAppointmentByCustomer(String appointmentId, {String? reason}) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index].status = AppointmentStatus.canceled;
      _appointments[index].cancelReason = reason ?? 'Canceled by customer';
      notifyListeners();
    }
  }

  void confirmAppointment(String appointmentId) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index].status = AppointmentStatus.confirmed;
      notifyListeners();
    }
  }

  void rejectAppointment(String appointmentId, {String? reason}) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index].status = AppointmentStatus.canceled;
      _appointments[index].cancelReason = reason ?? 'Rejected by barber';
      notifyListeners();
    }
  }

  void startService(String appointmentId) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index].status = AppointmentStatus.inProgress;
      notifyListeners();
    }
  }

  void completeService({
    required String appointmentId,
    required String serviceNotes,
    required List<String> photos,
    required double actualPriceCharged,
    required double tipAmount,
    required PaymentMethod paymentMethod,
  }) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      final apt = _appointments[index];
      apt.status = AppointmentStatus.completed;
      apt.serviceNotes = serviceNotes;
      apt.haircutPhotos = photos;
      apt.actualPriceCharged = actualPriceCharged;
      apt.tipAmount = tipAmount;
      apt.paymentMethod = paymentMethod;
      notifyListeners();
    }
  }

  void markNoShow(String appointmentId) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index].status = AppointmentStatus.noShow;
      notifyListeners();
    }
  }

  // Expenses CRUD
  void addExpense({
    required String title,
    required ExpenseCategory category,
    required double amount,
    required PaymentMethod paymentMethod,
    DateTime? date,
    String? notes,
    String? receiptPhoto,
  }) {
    final newExp = ExpenseModel(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      barberInternalId: 'UID-BARB-7X92K',
      title: title,
      category: category,
      amount: amount,
      date: date ?? DateTime.now(),
      paymentMethod: paymentMethod,
      notes: notes,
      receiptPhoto: receiptPhoto,
    );
    _expenses.insert(0, newExp);
    notifyListeners();
  }

  void updateExpense({
    required String id,
    required String title,
    required ExpenseCategory category,
    required double amount,
    required PaymentMethod paymentMethod,
    required DateTime date,
    String? notes,
    String? receiptPhoto,
  }) {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      _expenses[index] = ExpenseModel(
        id: id,
        barberInternalId: _expenses[index].barberInternalId,
        title: title,
        category: category,
        amount: amount,
        date: date,
        paymentMethod: paymentMethod,
        notes: notes,
        receiptPhoto: receiptPhoto,
      );
      notifyListeners();
    }
  }

  void deleteExpense(String expenseId) {
    _expenses.removeWhere((e) => e.id == expenseId);
    notifyListeners();
  }

  // Services Queries & CRUD
  List<BarberServiceItem> getServicesForBarber(String barberId, BusinessType businessType) {
    final existing = _services.where((s) => s.barberInternalId == barberId).toList();
    if (existing.isNotEmpty) {
      return existing;
    }
    // Seed default catalog for this provider & business type if empty
    final seeded = getDefaultServicesForBusinessType(businessType, barberId);
    _services.addAll(seeded);
    return seeded;
  }

  void ensureServicesForNewBarber(String barberId, BusinessType businessType) {
    if (!_services.any((s) => s.barberInternalId == barberId)) {
      _services.addAll(getDefaultServicesForBusinessType(businessType, barberId));
      notifyListeners();
    }
  }

  void addService({
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    required String category,
    String? barberId,
  }) {
    final newService = BarberServiceItem(
      id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
      barberInternalId: barberId ?? 'UID-BARB-7X92K',
      name: name,
      description: description,
      price: price,
      durationMinutes: durationMinutes,
      category: category,
    );
    _services.add(newService);
    notifyListeners();
  }

  void updateService({
    required String id,
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    required String category,
    required bool isActive,
  }) {
    final index = _services.indexWhere((s) => s.id == id);
    if (index != -1) {
      _services[index] = BarberServiceItem(
        id: id,
        barberInternalId: _services[index].barberInternalId,
        name: name,
        description: description,
        price: price,
        durationMinutes: durationMinutes,
        category: category,
        isActive: isActive,
      );
      notifyListeners();
    }
  }

  void deleteService(String serviceId) {
    _services.removeWhere((s) => s.id == serviceId);
    notifyListeners();
  }

  void toggleServiceStatus(String serviceId) {
    final index = _services.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      _services[index].isActive = !_services[index].isActive;
      notifyListeners();
    }
  }

  // Period-Aware Financial Analytics Methods ('DAY', 'WEEK', 'MONTH', 'YEAR', 'CUSTOM')
  bool _isWithinPeriod(DateTime date, String period, [DateTimeRange? customRange]) {
    final now = DateTime.now();
    if (period == 'CUSTOM' && customRange != null) {
      final start = DateTime(customRange.start.year, customRange.start.month, customRange.start.day);
      final end = DateTime(customRange.end.year, customRange.end.month, customRange.end.day, 23, 59, 59);
      return (date.isAfter(start.subtract(const Duration(seconds: 1))) && date.isBefore(end.add(const Duration(seconds: 1))));
    }
    if (period == 'DAY') {
      return date.year == now.year && date.month == now.month && date.day == now.day;
    } else if (period == 'WEEK') {
      final weekAgo = now.subtract(const Duration(days: 7));
      return date.isAfter(weekAgo);
    } else if (period == 'MONTH') {
      return date.year == now.year && date.month == now.month;
    } else if (period == 'YEAR') {
      return date.year == now.year;
    }
    return true;
  }

  // Module — Reports & Analytics Master Engine
  Map<String, dynamic> getReportsAndAnalytics({
    String period = 'MONTH',
    DateTimeRange? customRange,
  }) {
    final periodApts = _appointments.where((a) => _isWithinPeriod(a.dateTime, period, customRange)).toList();
    final completedApts = periodApts.where((a) => a.status == AppointmentStatus.completed).toList();
    final canceledApts = periodApts.where((a) => a.status == AppointmentStatus.canceled).toList();
    final noShowApts = periodApts.where((a) => a.status == AppointmentStatus.noShow).toList();
    final confirmedApts = periodApts.where((a) => a.status == AppointmentStatus.confirmed || a.status == AppointmentStatus.inProgress).toList();

    final totalAppointmentsCount = periodApts.length;
    final totalCompletedCount = completedApts.length;
    final totalCanceledCount = canceledApts.length;
    final totalNoShowCount = noShowApts.length;

    final confirmationRate = totalAppointmentsCount > 0
        ? ((totalCompletedCount + confirmedApts.length) / totalAppointmentsCount) * 100
        : 85.0;

    // Financial metrics
    final serviceRev = completedApts.fold(0.0, (sum, a) => sum + (a.actualPriceCharged ?? a.basePrice));
    final tipsRev = completedApts.fold(0.0, (sum, a) => sum + (a.tipAmount ?? 0.0));
    final grossIncome = serviceRev + tipsRev;

    final periodExpenses = _expenses.where((e) => _isWithinPeriod(e.date, period, customRange)).fold(0.0, (sum, e) => sum + e.amount);
    final netProfit = grossIncome - periodExpenses;
    final avgTicket = totalCompletedCount > 0 ? serviceRev / totalCompletedCount : 0.0;

    // Client Analytics
    final uniqueClientIds = periodApts.map((a) => a.customerId).toSet();
    final totalClientsCount = uniqueClientIds.isNotEmpty ? uniqueClientIds.length : 12;

    final clientAptCounts = <String, int>{};
    for (var a in _appointments) {
      clientAptCounts[a.customerId] = (clientAptCounts[a.customerId] ?? 0) + 1;
    }

    final recurringClientsCount = uniqueClientIds.where((cid) => (clientAptCounts[cid] ?? 0) > 1).length;
    final newClientsCount = (totalClientsCount - recurringClientsCount).clamp(0, totalClientsCount);
    final inactiveClientsCount = 2; // Clients with no appointments in >30 days

    // Service analytics
    final serviceCounts = <String, int>{};
    final serviceRevenues = <String, double>{};

    for (var s in _services) {
      serviceCounts[s.name] = 0;
      serviceRevenues[s.name] = 0.0;
    }

    for (var a in completedApts) {
      final sName = a.serviceName;
      final price = a.actualPriceCharged ?? a.basePrice;
      serviceCounts[sName] = (serviceCounts[sName] ?? 0) + 1;
      serviceRevenues[sName] = (serviceRevenues[sName] ?? 0) + price;
    }

    final sortedEntries = serviceCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final mostRequestedServices = sortedEntries.take(3).map((e) => {
      'name': e.key,
      'count': e.value,
      'revenue': serviceRevenues[e.key] ?? 0.0,
    }).toList();

    final leastRequestedServices = sortedEntries.reversed.take(3).map((e) => {
      'name': e.key,
      'count': e.value,
      'revenue': serviceRevenues[e.key] ?? 0.0,
    }).toList();

    // Busiest hours distribution (9 AM to 6 PM)
    final hourlyCounts = <int, int>{};
    for (var h = 9; h <= 18; h++) {
      hourlyCounts[h] = 0;
    }
    for (var a in periodApts) {
      final hour = a.dateTime.hour;
      if (hourlyCounts.containsKey(hour)) {
        hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
      }
    }

    return {
      'period': period,
      'customRange': customRange,
      // Clients
      'totalClients': totalClientsCount,
      'newClients': newClientsCount,
      'recurringClients': recurringClientsCount,
      'inactiveClients': inactiveClientsCount,
      // Appointments
      'totalAppointments': totalAppointmentsCount,
      'completedAppointments': totalCompletedCount,
      'canceledAppointments': totalCanceledCount,
      'noShowAppointments': totalNoShowCount,
      'confirmationRate': confirmationRate,
      'hourlyCounts': hourlyCounts,
      // Finances
      'serviceRevenue': serviceRev,
      'tipsRevenue': tipsRev,
      'grossIncome': grossIncome,
      'expenses': periodExpenses,
      'netProfit': netProfit,
      'avgTicket': avgTicket,
      // Services
      'mostRequestedServices': mostRequestedServices,
      'leastRequestedServices': leastRequestedServices,
      'serviceRevenues': serviceRevenues,
    };
  }

  Map<String, Map<String, dynamic>> getServiceTypeAnalytics([String period = 'DAY']) {
    final Map<String, Map<String, dynamic>> analytics = {};
    final periodApts = _appointments.where(
      (a) => a.status == AppointmentStatus.completed && _isWithinPeriod(a.dateTime, period),
    );

    for (var apt in periodApts) {
      final name = apt.serviceName;
      final price = apt.actualPriceCharged ?? apt.basePrice;
      if (!analytics.containsKey(name)) {
        analytics[name] = {
          'count': 0,
          'totalRevenue': 0.0,
          'avgPrice': 0.0,
        };
      }
      analytics[name]!['count'] = (analytics[name]!['count'] as int) + 1;
      analytics[name]!['totalRevenue'] = (analytics[name]!['totalRevenue'] as double) + price;
    }

    analytics.forEach((key, val) {
      final count = val['count'] as int;
      final total = val['totalRevenue'] as double;
      val['avgPrice'] = count > 0 ? total / count : 0.0;
    });

    return analytics;
  }

  double getServiceRevenue([String period = 'DAY']) {
    return _appointments
        .where((a) => a.status == AppointmentStatus.completed && _isWithinPeriod(a.dateTime, period))
        .fold(0.0, (sum, a) => sum + (a.actualPriceCharged ?? a.basePrice));
  }

  double getTips([String period = 'DAY']) {
    return _appointments
        .where((a) => a.status == AppointmentStatus.completed && _isWithinPeriod(a.dateTime, period))
        .fold(0.0, (sum, a) => sum + (a.tipAmount ?? 0.0));
  }

  double getTotalRevenue([String period = 'DAY']) => getServiceRevenue(period) + getTips(period);

  double getExpensesAmount([String period = 'DAY']) {
    return _expenses
        .where((e) => _isWithinPeriod(e.date, period))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double getNetProfit([String period = 'DAY']) => getTotalRevenue(period) - getExpensesAmount(period);

  double getCashInPocket([String period = 'DAY']) {
    return _appointments
        .where((a) => a.status == AppointmentStatus.completed && _isWithinPeriod(a.dateTime, period) && a.paymentMethod == PaymentMethod.cash)
        .fold(0.0, (sum, a) => sum + a.totalPriceReceived);
  }

  double getDigitalPayments([String period = 'DAY']) {
    return _appointments
        .where((a) => a.status == AppointmentStatus.completed && _isWithinPeriod(a.dateTime, period) && a.paymentMethod != PaymentMethod.cash)
        .fold(0.0, (sum, a) => sum + a.totalPriceReceived);
  }

  double getAverageTicket([String period = 'DAY']) {
    final count = getCompletedCount(period);
    if (count == 0) return 0.0;
    return getServiceRevenue(period) / count;
  }

  double getAverageTipPercentage([String period = 'DAY']) {
    final serviceRev = getServiceRevenue(period);
    if (serviceRev == 0) return 0.0;
    return (getTips(period) / serviceRev) * 100;
  }

  int getCompletedCount([String period = 'DAY']) {
    return _appointments
        .where((a) => a.status == AppointmentStatus.completed && _isWithinPeriod(a.dateTime, period))
        .length;
  }

  // Legacy getters for backward compatibility
  double get todayServiceRevenue => getServiceRevenue('DAY');
  double get todayTips => getTips('DAY');
  double get todayTotalRevenue => getTotalRevenue('DAY');
  double get totalExpensesAmount => getExpensesAmount('DAY');
  double get estimatedNetProfit => getNetProfit('DAY');
  int get todayCompletedCount => getCompletedCount('DAY');

  // Module 9 Tax Center Calculation Engine (US Self-Employment & Schedule C)
  TaxCalculationResult calculateTaxSummary({
    int targetYear = 2026,
    double reservePercentage = 0.25,
  }) {
    final yearApts = _appointments.where((a) =>
        a.status == AppointmentStatus.completed &&
        a.dateTime.year == targetYear);

    final grossServices = yearApts.fold(0.0, (sum, a) => sum + (a.actualPriceCharged ?? a.basePrice));
    final totalTips = yearApts.fold(0.0, (sum, a) => sum + (a.tipAmount ?? 0.0));
    final totalGross = grossServices + totalTips;

    final yearExpenses = _expenses.where((e) => e.date.year == targetYear);
    final totalExpenses = yearExpenses.fold(0.0, (sum, e) => sum + e.amount);

    final Map<String, double> expensesByCategory = {};
    for (var cat in ExpenseCategory.values) {
      final catAmount = yearExpenses
          .where((e) => e.category == cat)
          .fold(0.0, (sum, e) => sum + e.amount);
      if (catAmount > 0) {
        expensesByCategory[cat.displayName] = catAmount;
      }
    }

    final netProfit = (totalGross - totalExpenses).clamp(0.0, double.infinity);

    // US Self-Employment Tax: 15.3% on 92.35% of net profit
    final seTaxableNet = netProfit * 0.9235;
    final estimatedSeTax = seTaxableNet * 0.153;

    // Estimated Federal & State Income Tax (~12% effective rate)
    final estimatedIncomeTax = netProfit * 0.12;

    final totalEstimatedTax = estimatedSeTax + estimatedIncomeTax;
    final quarterlyPayment = totalEstimatedTax / 4;
    final recommendedReserve = netProfit * reservePercentage;

    // Annualized Projection (based on current day of year)
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(targetYear, 1, 1)).inDays + 1;
    final daysInYear = 365;
    final factor = (dayOfYear > 0 && dayOfYear <= 365) ? (daysInYear / dayOfYear) : 1.0;

    final annualizedRevenue = totalGross * factor;
    final annualizedTax = totalEstimatedTax * factor;

    return TaxCalculationResult(
      year: targetYear,
      grossServicesRevenue: grossServices,
      totalTips: totalTips,
      totalGrossIncome: totalGross,
      totalDeductibleExpenses: totalExpenses,
      netSelfEmploymentIncome: netProfit,
      estimatedSelfEmploymentTax: estimatedSeTax,
      estimatedIncomeTax: estimatedIncomeTax,
      totalEstimatedTaxLiability: totalEstimatedTax,
      quarterlyEstimatedPayment: quarterlyPayment,
      reservePercentage: reservePercentage,
      recommendedTaxReserveAmount: recommendedReserve,
      annualizedProjectedIncome: annualizedRevenue,
      annualizedProjectedTax: annualizedTax,
      expensesByCategory: expensesByCategory,
    );
  }

  // Super Admin SaaS Management Actions
  void suspendBarberAccount(String internalId) {
    final index = _allBarberUsers.indexWhere((b) => b.internalId == internalId);
    if (index != -1) {
      _allBarberUsers[index] = _allBarberUsers[index].copyWith(
        subscriptionStatus: SubscriptionStatus.suspended,
      );
      notifyListeners();
    }
  }

  void reactivateBarberAccount(String internalId) {
    final index = _allBarberUsers.indexWhere((b) => b.internalId == internalId);
    if (index != -1) {
      _allBarberUsers[index] = _allBarberUsers[index].copyWith(
        subscriptionStatus: SubscriptionStatus.active,
      );
      notifyListeners();
    }
  }

  void retryFailedPayment(String internalId) {
    final index = _allBarberUsers.indexWhere((b) => b.internalId == internalId);
    if (index != -1) {
      _allBarberUsers[index] = _allBarberUsers[index].copyWith(
        subscriptionStatus: SubscriptionStatus.active,
        nextBillingDate: DateTime.now().add(const Duration(days: 30)),
      );
      notifyListeners();
    }
  }

  void addGlobalPromo(String code, double discountPercent, int validDays) {
    _globalPromos.insert(
      0,
      SaaSGlobalPromo(
        id: 'promo_${DateTime.now().millisecondsSinceEpoch}',
        code: code.toUpperCase().trim(),
        discountPercent: discountPercent,
        expiresAt: DateTime.now().add(Duration(days: validDays)),
        isActive: true,
        timesUsed: 0,
      ),
    );
    notifyListeners();
  }

  void togglePromoStatus(String promoId) {
    final index = _globalPromos.indexWhere((p) => p.id == promoId);
    if (index != -1) {
      _globalPromos[index].isActive = !_globalPromos[index].isActive;
      notifyListeners();
    }
  }

  void broadcastAnnouncement(String title, String message, String audience) {
    _globalAnnouncements.insert(
      0,
      SaaSAnnouncement(
        id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        createdAt: DateTime.now(),
        targetAudience: audience,
      ),
    );
    notifyListeners();
  }
}
