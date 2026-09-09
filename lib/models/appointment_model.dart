enum AppointmentStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  canceled,
  noShow,
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get displayName {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.canceled:
        return 'Canceled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }
}

enum PaymentMethod {
  cash,
  card,
  applePay,
  googlePay,
  transfer,
  other,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Credit / Debit Card';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.transfer:
        return 'Bank Transfer';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}

class AppointmentModel {
  final String id;
  final String barberInternalId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? customerPhoto;
  final DateTime dateTime;
  final int durationMinutes;
  final String serviceName;
  final double basePrice;
  final String? customerNotes;
  
  // Post-service closure fields
  AppointmentStatus status;
  String? serviceNotes;
  List<String> haircutPhotos;
  double? actualPriceCharged;
  double? tipAmount;
  PaymentMethod? paymentMethod;
  String? cancelReason;

  AppointmentModel({
    required this.id,
    required this.barberInternalId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.customerPhoto,
    required this.dateTime,
    required this.durationMinutes,
    required this.serviceName,
    required this.basePrice,
    this.customerNotes,
    this.status = AppointmentStatus.pending,
    this.serviceNotes,
    this.haircutPhotos = const [],
    this.actualPriceCharged,
    this.tipAmount,
    this.paymentMethod,
    this.cancelReason,
  });

  double get totalPriceReceived {
    final price = actualPriceCharged ?? basePrice;
    final tip = tipAmount ?? 0.0;
    return price + tip;
  }

  DateTime get endTime => dateTime.add(Duration(minutes: durationMinutes));

  String get formattedTime {
    final hour12 = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dateTime.minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }

  bool isOverlappingWith(DateTime otherStart, int otherDurationMinutes) {
    if (status == AppointmentStatus.canceled || status == AppointmentStatus.noShow) {
      return false;
    }
    final otherEnd = otherStart.add(Duration(minutes: otherDurationMinutes));
    return dateTime.isBefore(otherEnd) && otherStart.isBefore(endTime);
  }
}
