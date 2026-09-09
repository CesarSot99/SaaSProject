import 'package:flutter/material.dart';
import 'appointment_model.dart';

enum ExpenseCategory {
  products,
  equipment,
  rent,
  utilities,
  cleaning,
  marketing,
  maintenance,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.products:
        return 'Products';
      case ExpenseCategory.equipment:
        return 'Equipment';
      case ExpenseCategory.rent:
        return 'Rent & Lease';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.cleaning:
        return 'Cleaning & Hygiene';
      case ExpenseCategory.marketing:
        return 'Marketing & Ads';
      case ExpenseCategory.maintenance:
        return 'Maintenance';
      case ExpenseCategory.other:
        return 'Other Expenses';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.products:
        return Icons.shopping_bag_outlined;
      case ExpenseCategory.equipment:
        return Icons.content_cut_rounded;
      case ExpenseCategory.rent:
        return Icons.store_rounded;
      case ExpenseCategory.utilities:
        return Icons.bolt_rounded;
      case ExpenseCategory.cleaning:
        return Icons.cleaning_services_rounded;
      case ExpenseCategory.marketing:
        return Icons.campaign_rounded;
      case ExpenseCategory.maintenance:
        return Icons.build_circle_outlined;
      case ExpenseCategory.other:
        return Icons.receipt_long_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.products:
        return const Color(0xFFFF9800); // Amber/Orange
      case ExpenseCategory.equipment:
        return const Color(0xFF2196F3); // Blue
      case ExpenseCategory.rent:
        return const Color(0xFF9C27B0); // Purple
      case ExpenseCategory.utilities:
        return const Color(0xFFFFC107); // Yellow
      case ExpenseCategory.cleaning:
        return const Color(0xFF00BCD4); // Cyan
      case ExpenseCategory.marketing:
        return const Color(0xFFE91E63); // Pink
      case ExpenseCategory.maintenance:
        return const Color(0xFF795548); // Brown
      case ExpenseCategory.other:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }
}

class ExpenseModel {
  final String id;
  final String barberInternalId;
  final String title;
  final ExpenseCategory category;
  final double amount;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final String? notes;
  final String? receiptPhoto;

  ExpenseModel({
    required this.id,
    required this.barberInternalId,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    this.notes,
    this.receiptPhoto,
  });

  ExpenseModel copyWith({
    String? id,
    String? barberInternalId,
    String? title,
    ExpenseCategory? category,
    double? amount,
    DateTime? date,
    PaymentMethod? paymentMethod,
    String? notes,
    String? receiptPhoto,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      barberInternalId: barberInternalId ?? this.barberInternalId,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      receiptPhoto: receiptPhoto ?? this.receiptPhoto,
    );
  }
}

