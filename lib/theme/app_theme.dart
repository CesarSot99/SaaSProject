import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New Royal Blue & Vivid Purple Design System Palette
  static const Color primary = Color(0xFF2563EB); // Primary Blue (#2563EB)
  static const Color primaryDark = Color(0xFF1D4ED8); // Blue Dark (#1D4ED8)
  static const Color primaryLight = Color(0xFFDBEAFE); // Blue Light (#DBEAFE)

  static const Color accent = Color(0xFF7C3AED); // Primary Purple (#7C3AED)
  static const Color accentDark = Color(0xFF6D28D9); // Purple Dark (#6D28D9)
  static const Color accentLight = Color(0xFFEDE9FE); // Purple Light (#EDE9FE)

  static const Color secondary = Color(0xFFDBEAFE); // Blue Light for containers
  static const Color tertiary = Color(0xFF7C3AED); // Primary Purple for highlights
  static const Color neutral = Color(0xFF64748B); // Slate Muted

  static const Color background = Color(0xFFF8FAFC); // Clean Background (#F8FAFC)
  static const Color surface = Color(0xFFFFFFFF); // Card & Modal White (#FFFFFF)
  static const Color cardBg = Color(0xFFFFFFFF); // Card Background (#FFFFFF)
  static const Color surfaceLight = Color(0xFFEDE9FE); // Soft Purple Tint (#EDE9FE)

  static const Color textPrimary = Color(0xFF0F172A); // Main Text (#0F172A)
  static const Color textSecondary = Color(0xFF475569); // Dark Slate Subtitle Text
  static const Color textMuted = Color(0xFF64748B); // Muted Text (#64748B)
  static const Color borderColor = Color(0xFFE2E8F0); // Border (#E2E8F0)

  static const Color success = Color(0xFF16A34A); // Income / Success (#16A34A)
  static const Color error = Color(0xFFDC2626); // Expense / Danger (#DC2626)
  static const Color warning = Color(0xFFF59E0B); // Warning (#F59E0B)
  static const Color info = Color(0xFF0EA5E9); // Info (#0EA5E9)

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        tertiary: tertiary,
        surface: surface,
        error: error,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: primary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.plusJakartaSans(color: textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),
    );
  }
}

