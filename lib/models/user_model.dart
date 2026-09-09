import 'package:flutter/material.dart';

enum UserRole { barber, customer, superAdmin }

enum SubscriptionStatus {
  active,
  trial,
  pendingPayment,
  canceled,
  suspended,
}

extension SubscriptionStatusExtension on SubscriptionStatus {
  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'ACTIVE';
      case SubscriptionStatus.trial:
        return 'TRIAL';
      case SubscriptionStatus.pendingPayment:
        return 'PENDING PAYMENT';
      case SubscriptionStatus.canceled:
        return 'CANCELED';
      case SubscriptionStatus.suspended:
        return 'SUSPENDED';
    }
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final String period;
  final String description;
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
    this.isPopular = false,
  });
}

class AppUser {
  final String internalId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final UserRole role;
  final String? avatarUrl;

  AppUser({
    required this.internalId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl,
  });

  String get fullName => '$firstName $lastName';
}

class SuperAdminUser extends AppUser {
  SuperAdminUser({
    required super.internalId,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    super.avatarUrl,
  }) : super(role: UserRole.superAdmin);
}

enum BusinessType {
  barberShop,
  hairSalon,
  nailStudio,
  lashAndBrow,
  esthetician,
}

extension BusinessTypeExtension on BusinessType {
  String get displayName {
    switch (this) {
      case BusinessType.barberShop:
        return 'Barber Shop';
      case BusinessType.hairSalon:
        return 'Hair & Beauty Salon';
      case BusinessType.nailStudio:
        return 'Nail Studio & Spa';
      case BusinessType.lashAndBrow:
        return 'Lash & Brow Studio';
      case BusinessType.esthetician:
        return 'Esthetician & Skincare';
    }
  }

  String get professionalTitle {
    switch (this) {
      case BusinessType.barberShop:
        return 'Barber';
      case BusinessType.hairSalon:
        return 'Stylist';
      case BusinessType.nailStudio:
        return 'Nail Technician';
      case BusinessType.lashAndBrow:
        return 'Lash Specialist';
      case BusinessType.esthetician:
        return 'Esthetician';
    }
  }

  String get accountTitle => 'Create your $professionalTitle Account';

  String get accountSubTitle => 'Enter your personal details and business information to continue.';

  String get shopFieldLabel {
    switch (this) {
      case BusinessType.barberShop:
        return 'Barber Shop Name';
      case BusinessType.hairSalon:
        return 'Salon / Studio Name';
      case BusinessType.nailStudio:
        return 'Nail Studio Name';
      case BusinessType.lashAndBrow:
        return 'Lash & Brow Studio Name';
      case BusinessType.esthetician:
        return 'Skincare Clinic Name';
    }
  }

  String get shopFieldHint {
    switch (this) {
      case BusinessType.barberShop:
        return 'e.g. Elite Barber Shop';
      case BusinessType.hairSalon:
        return 'e.g. Glamour Hair & Beauty Salon';
      case BusinessType.nailStudio:
        return 'e.g. Luxe Nail Lounge';
      case BusinessType.lashAndBrow:
        return 'e.g. Velvet Lash & Brow Studio';
      case BusinessType.esthetician:
        return 'e.g. Glow Skincare Clinic';
    }
  }

  String get emailHint {
    switch (this) {
      case BusinessType.barberShop:
        return 'carlos@barber.com';
      case BusinessType.hairSalon:
        return 'stylist@salon.com';
      case BusinessType.nailStudio:
        return 'tech@naillounge.com';
      case BusinessType.lashAndBrow:
        return 'specialist@lashstudio.com';
      case BusinessType.esthetician:
        return 'info@skincare.com';
    }
  }

  String get shopValidationMsg => 'Please enter your ${shopFieldLabel.toLowerCase()}';

  String get codePrefix {
    switch (this) {
      case BusinessType.barberShop:
        return 'BARB';
      case BusinessType.hairSalon:
        return 'HAIR';
      case BusinessType.nailStudio:
        return 'NAIL';
      case BusinessType.lashAndBrow:
        return 'LASH';
      case BusinessType.esthetician:
        return 'SKIN';
    }
  }

  List<String> get serviceCategories {
    switch (this) {
      case BusinessType.hairSalon:
        return const ['All', 'Haircut & Style', 'Coloring', 'Treatments', 'Styling'];
      case BusinessType.nailStudio:
        return const ['All', 'Manicure', 'Pedicure', 'Acrylic & Gel', 'Nail Art'];
      case BusinessType.lashAndBrow:
        return const ['All', 'Lash Extensions', 'Lash Lift', 'Brow Shaping & Tint'];
      case BusinessType.esthetician:
        return const ['All', 'Facials', 'Skin Resurfacing', 'Peels & Serums'];
      case BusinessType.barberShop:
        return const ['All', 'Haircut', 'Haircut + Beard', 'Beard', 'Kids Haircut', 'Line Up', 'Treatments'];
    }
  }

  IconData get icon {
    switch (this) {
      case BusinessType.hairSalon:
        return Icons.face_retouching_natural_rounded;
      case BusinessType.nailStudio:
        return Icons.back_hand_rounded;
      case BusinessType.lashAndBrow:
        return Icons.remove_red_eye_rounded;
      case BusinessType.esthetician:
        return Icons.spa_rounded;
      case BusinessType.barberShop:
        return Icons.content_cut_rounded;
    }
  }
}

class BarberUser extends AppUser {
  final String shopName;
  final String shopLocation;
  final String publicCode; // Alias for backward compatibility (same as phone)
  final String planId;
  final SubscriptionStatus subscriptionStatus;
  final DateTime createdAt;
  final DateTime nextBillingDate;
  final BusinessType businessType;
  final int bufferTimeMinutes;

  BarberUser({
    required super.internalId,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required this.shopName,
    required this.shopLocation,
    String? publicCode,
    required this.planId,
    required this.subscriptionStatus,
    required this.createdAt,
    required this.nextBillingDate,
    this.businessType = BusinessType.barberShop,
    this.bufferTimeMinutes = 5,
    super.avatarUrl,
  })  : publicCode = publicCode ?? phone,
        super(role: UserRole.barber);

  BarberUser copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? shopName,
    String? shopLocation,
    String? publicCode,
    String? planId,
    SubscriptionStatus? subscriptionStatus,
    DateTime? nextBillingDate,
    BusinessType? businessType,
    int? bufferTimeMinutes,
    String? avatarUrl,
  }) {
    return BarberUser(
      internalId: internalId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      shopName: shopName ?? this.shopName,
      shopLocation: shopLocation ?? this.shopLocation,
      publicCode: publicCode ?? this.publicCode,
      planId: planId ?? this.planId,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      createdAt: createdAt,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      businessType: businessType ?? this.businessType,
      bufferTimeMinutes: bufferTimeMinutes ?? this.bufferTimeMinutes,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class CustomerUser extends AppUser {
  final String associatedBarberPhone; // Stylist Phone Number entered by customer
  final String associatedBarberId;    // Internal UID of associated professional
  final DateTime createdAt;
  String privateNotes;                // Barber's private CRM notes (hidden from customer)
  List<String> galleryPhotos;        // Barber's private haircut reference photos

  CustomerUser({
    required super.internalId,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required this.associatedBarberPhone,
    required this.associatedBarberId,
    DateTime? createdAt,
    this.privateNotes = '',
    List<String>? galleryPhotos,
    super.avatarUrl,
  })  : createdAt = createdAt ?? DateTime.now(),
        galleryPhotos = galleryPhotos ?? [],
        super(role: UserRole.customer);

  String get assignedBarberPhone => associatedBarberPhone;
  String get assignedBarberCode => associatedBarberPhone; // Alias
  String get assignedBarberName => 'Carlos Rodriguez';

  CustomerUser copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? associatedBarberPhone,
    String? associatedBarberId,
    String? privateNotes,
    List<String>? galleryPhotos,
    String? avatarUrl,
  }) {
    return CustomerUser(
      internalId: internalId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      associatedBarberPhone: associatedBarberPhone ?? this.associatedBarberPhone,
      associatedBarberId: associatedBarberId ?? this.associatedBarberId,
      createdAt: createdAt,
      privateNotes: privateNotes ?? this.privateNotes,
      galleryPhotos: galleryPhotos ?? this.galleryPhotos,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class SaaSGlobalPromo {
  final String id;
  final String code;
  final double discountPercent;
  final DateTime expiresAt;
  bool isActive;
  int timesUsed;

  SaaSGlobalPromo({
    required this.id,
    required this.code,
    required this.discountPercent,
    required this.expiresAt,
    this.isActive = true,
    this.timesUsed = 0,
  });
}

class SaaSAnnouncement {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final String targetAudience; // 'ALL', 'BARBERS', 'CUSTOMERS'

  SaaSAnnouncement({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.targetAudience = 'ALL',
  });
}
