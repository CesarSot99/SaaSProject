import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'barber_data_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initMockData();
  }

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  // Static subscription plans translated to English
  final List<SubscriptionPlan> availablePlans = const [
    SubscriptionPlan(
      id: 'plan_basic',
      name: 'Basic Plan',
      price: 15.0,
      period: '/mo',
      description: 'Ideal for independent barbers starting out.',
      features: [
        'Up to 50 linked clients',
        'Digital appointment calendar',
        'Basic confirmation notifications',
        'Unique client public code',
      ],
    ),
    SubscriptionPlan(
      id: 'plan_pro',
      name: 'Professional Plan',
      price: 29.0,
      period: '/mo',
      description: 'For barbers with steady client flow looking to scale their business.',
      isPopular: true,
      features: [
        'Unlimited linked clients',
        'Automated appointment reminders',
        'Advanced metrics & analytics',
        'Featured public profile',
        'Priority technical support',
      ],
    ),
    SubscriptionPlan(
      id: 'plan_premium',
      name: 'Premium Plan',
      price: 49.0,
      period: '/mo',
      description: 'Complete solution with marketing and enterprise management.',
      features: [
        'All Professional Plan features',
        'Online payments & deposit management',
        'Promotions & client loyalty module',
        '24/7 VIP support with dedicated advisor',
      ],
    ),
  ];

  final List<BarberUser> _barbers = [];
  final List<CustomerUser> _customers = [];

  void _initMockData() {
    // Initial mock Barber according to specs (Carlos Rodriguez +1 (555) 987-6543)
    final initialBarber = BarberUser(
      internalId: 'UID-BARB-7X92K',
      firstName: 'Carlos',
      lastName: 'Rodriguez',
      email: 'carlos@barber.com',
      phone: '+1 (555) 987-6543',
      shopName: 'Elite Barber Shop',
      shopLocation: '45 Main St, Suite 102',
      publicCode: 'BARB-7X92K',
      planId: 'plan_pro',
      subscriptionStatus: SubscriptionStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      nextBillingDate: DateTime.now().add(const Duration(days: 30)),
    );
    _barbers.add(initialBarber);

    // Initial mock Customers (associated with Carlos)
    final now = DateTime.now();
    _customers.addAll([
      CustomerUser(
        internalId: 'UID-CUST-101',
        firstName: 'John',
        lastName: 'Smith',
        email: 'john@client.com',
        phone: '+1 (555) 123-4567',
        associatedBarberPhone: '+1 (555) 987-6543',
        associatedBarberId: 'UID-BARB-7X92K',
        createdAt: now.subtract(const Duration(days: 90)),
        privateNotes: 'Prefers #2 skin fade, leave 2 inches on top. Scalp sensitive to alcohol aftershave. Always drinks espresso.',
        galleryPhotos: [
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400',
        ],
      ),
      CustomerUser(
        internalId: 'UID-CUST-102',
        firstName: 'Robert',
        lastName: 'Garcia',
        email: 'robert@client.com',
        phone: '+1 (555) 444-1234',
        associatedBarberPhone: '+1 (555) 987-6543',
        associatedBarberId: 'UID-BARB-7X92K',
        createdAt: now.subtract(const Duration(days: 5)),
        privateNotes: 'New client referred by John. Wants sharp beard line up and pompadour styling.',
        galleryPhotos: [
          'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400',
        ],
      ),
      CustomerUser(
        internalId: 'UID-CUST-103',
        firstName: 'Elena',
        lastName: 'Rostova',
        email: 'elena@client.com',
        phone: '+1 (555) 777-8899',
        associatedBarberPhone: '+1 (555) 987-6543',
        associatedBarberId: 'UID-BARB-7X92K',
        createdAt: now.subtract(const Duration(days: 60)),
        privateNotes: 'Hair trim and treatment. Prefers organic conditioning products.',
        galleryPhotos: [],
      ),
    ]);
  }

  // Helper method to extract digits from phone input
  String _cleanPhoneDigits(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  // Validate stylist by Phone Number or Code
  BarberUser? validateStylistPhone(String input) {
    final cleanInputDigits = _cleanPhoneDigits(input);
    final cleanText = input.trim().toUpperCase();

    try {
      return _barbers.firstWhere((b) {
        final bDigits = _cleanPhoneDigits(b.phone);
        if (cleanInputDigits.isNotEmpty && bDigits.isNotEmpty && bDigits.endsWith(cleanInputDigits)) {
          return true;
        }
        return b.publicCode.toUpperCase() == cleanText || b.phone == input.trim();
      });
    } catch (_) {
      return null;
    }
  }

  // Backward compatible alias for validateStylistPhone
  BarberUser? validateBarberCode(String code) => validateStylistPhone(code);

  // Generate unique barber code
  String generateUniqueBarberCode() {
    return 'BARB-${Random().nextInt(9000) + 1000}';
  }

  // Register Barber / Professional
  Future<BarberUser> registerBarber({
    required String firstName,
    required String lastName,
    required String shopName,
    required String shopLocation,
    required String phone,
    required String email,
    required String password,
    required String planId,
    BusinessType businessType = BusinessType.barberShop,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (_barbers.any((b) => b.email.toLowerCase() == email.toLowerCase()) ||
        _customers.any((c) => c.email.toLowerCase() == email.toLowerCase())) {
      throw Exception('This email address is already registered.');
    }

    final internalId = 'UID-BARB-${Random().nextInt(90000) + 10000}';
    final publicCode = generateUniqueBarberCode();

    final newBarber = BarberUser(
      internalId: internalId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      shopName: shopName,
      shopLocation: shopLocation,
      publicCode: publicCode,
      planId: planId,
      subscriptionStatus: SubscriptionStatus.active,
      createdAt: DateTime.now(),
      nextBillingDate: DateTime.now().add(const Duration(days: 30)),
      businessType: businessType,
    );

    _barbers.add(newBarber);
    BarberDataService().ensureServicesForNewBarber(newBarber.internalId, newBarber.businessType);
    _currentUser = newBarber;
    notifyListeners();
    return newBarber;
  }

  // Register Customer
  Future<CustomerUser> registerCustomer({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String barberCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final barber = validateBarberCode(barberCode);
    if (barber == null) {
      throw Exception('Invalid code. Check the code provided by your barber and try again.');
    }

    if (_customers.any((c) => c.email.toLowerCase() == email.toLowerCase()) ||
        _barbers.any((b) => b.email.toLowerCase() == email.toLowerCase())) {
      throw Exception('This email address is already registered.');
    }

    final internalId = 'UID-CUST-${Random().nextInt(90000) + 10000}';

    final newCustomer = CustomerUser(
      internalId: internalId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      associatedBarberPhone: barber.phone,
      associatedBarberId: barber.internalId,
    );

    _customers.add(newCustomer);
    _currentUser = newCustomer;
    notifyListeners();
    return newCustomer;
  }

  // Login
  Future<AppUser> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final cleanEmail = email.trim().toLowerCase();

    // Check if Super Admin
    if (cleanEmail == 'admin@barbersync.com' || cleanEmail == 'admin@saas.com' || cleanEmail == 'admin') {
      final superAdmin = SuperAdminUser(
        internalId: 'UID-SUPER-ADMIN-01',
        firstName: 'SaaS',
        lastName: 'Owner',
        email: 'admin@barbersync.com',
        phone: '+1 (800) 555-SAAS',
      );
      _currentUser = superAdmin;
      notifyListeners();
      return superAdmin;
    }

    // Try finding barber
    try {
      final barber = _barbers.firstWhere((b) => b.email.toLowerCase() == cleanEmail);
      _currentUser = barber;
      notifyListeners();
      return barber;
    } catch (_) {}

    // Try finding customer
    try {
      final customer = _customers.firstWhere((c) => c.email.toLowerCase() == cleanEmail);
      _currentUser = customer;
      notifyListeners();
      return customer;
    } catch (_) {}

    throw Exception('Invalid credentials. Check your email and password.');
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void setCurrentUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void restoreSuperAdmin() {
    _currentUser = SuperAdminUser(
      internalId: 'UID-SUPER-ADMIN-01',
      firstName: 'SaaS',
      lastName: 'Owner',
      email: 'admin@barbersync.com',
      phone: '+1 (800) 555-SAAS',
    );
    notifyListeners();
  }

  // Helper queries
  BarberUser? getBarberByInternalId(String internalId) {
    try {
      return _barbers.firstWhere((b) => b.internalId == internalId);
    } catch (_) {
      return null;
    }
  }

  List<CustomerUser> getCustomersForBarber(String barberInternalId) {
    return _customers.where((c) => c.associatedBarberId == barberInternalId).toList();
  }

  void updateCustomerPrivateNotes(String customerId, String notes) {
    try {
      final customer = _customers.firstWhere((c) => c.internalId == customerId);
      customer.privateNotes = notes;
      notifyListeners();
    } catch (_) {}
  }

  void addCustomerGalleryPhoto(String customerId, String photoUrl) {
    try {
      final customer = _customers.firstWhere((c) => c.internalId == customerId);
      customer.galleryPhotos.add(photoUrl);
      notifyListeners();
    } catch (_) {}
  }

  // Profile Administration Methods (Modulo Perfil & Configuración)
  void updateBarberProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String shopName,
    required String shopLocation,
    String? avatarUrl,
  }) {
    if (_currentUser is BarberUser) {
      final current = _currentUser as BarberUser;
      final updated = current.copyWith(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        shopName: shopName,
        shopLocation: shopLocation,
        avatarUrl: avatarUrl,
      );

      final index = _barbers.indexWhere((b) => b.internalId == current.internalId);
      if (index != -1) {
        _barbers[index] = updated;
      }
      _currentUser = updated;
      notifyListeners();
    }
  }

  void updateCustomerProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    String? avatarUrl,
  }) {
    if (_currentUser is CustomerUser) {
      final current = _currentUser as CustomerUser;
      final updated = current.copyWith(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        avatarUrl: avatarUrl,
      );

      final index = _customers.indexWhere((c) => c.internalId == current.internalId);
      if (index != -1) {
        _customers[index] = updated;
      }
      _currentUser = updated;
      notifyListeners();
    }
  }

  bool linkBarberToCustomer(String barberCodeOrPhone) {
    final barber = validateBarberCode(barberCodeOrPhone);
    if (barber == null) return false;

    if (_currentUser is CustomerUser) {
      final current = _currentUser as CustomerUser;
      final updated = current.copyWith(
        associatedBarberPhone: barber.phone,
        associatedBarberId: barber.internalId,
      );

      final index = _customers.indexWhere((c) => c.internalId == current.internalId);
      if (index != -1) {
        _customers[index] = updated;
      }
      _currentUser = updated;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool changePassword(String currentPassword, String newPassword) {
    if (currentPassword.isEmpty || newPassword.length < 6) {
      return false;
    }
    notifyListeners();
    return true;
  }
}
