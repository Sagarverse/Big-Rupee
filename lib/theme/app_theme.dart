import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF4F46E5);
  static const Color mintGreen = Color(0xFF22C55E);
  static const Color amber = Color(0xFFF59E0B);
  static const Color softRed = Color(0xFFEF4444);
  static const Color lightBg = Color(0xFFF9FAFB);
  static const Color darkText = Color(0xFF111827);
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.poppinsTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: mintGreen,
        error: softRed,
        surface: lightBg,
      ),
      scaffoldBackgroundColor: lightBg,
      textTheme: textTheme.copyWith(
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: darkText,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: darkText,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: darkText,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0.8,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: primaryBlue,
        secondary: mintGreen,
        error: softRed,
        surface: darkBg,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: textTheme.copyWith(
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        color: darkCard,
        elevation: 0.8,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
      ),
    );
  }
}
