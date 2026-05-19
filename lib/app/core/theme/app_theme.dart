import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2D2B8F);
  static const Color accent = Color(0xFF1D7A4F);
  static const Color background = Color(0xFFF0F2F8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color urgent = Color(0xFFEF4444);
  static const Color todayBadge = Color(0xFFE5E7EB);
  static const Color statBlue = Color(0xFFDCE8FA);

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final bodyTheme = base.textTheme.apply(
      fontFamily: 'Inter',
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: accent,
        surface: cardBackground,
        error: urgent,
      ),
      textTheme: bodyTheme.copyWith(
        displayLarge: bodyTheme.displayLarge?.copyWith(fontFamily: 'Poppins'),
        displayMedium: bodyTheme.displayMedium?.copyWith(fontFamily: 'Poppins'),
        displaySmall: bodyTheme.displaySmall?.copyWith(fontFamily: 'Poppins'),
        headlineLarge: bodyTheme.headlineLarge?.copyWith(fontFamily: 'Poppins'),
        headlineMedium:
            bodyTheme.headlineMedium?.copyWith(fontFamily: 'Poppins'),
        headlineSmall: bodyTheme.headlineSmall?.copyWith(fontFamily: 'Poppins'),
        titleLarge: bodyTheme.titleLarge?.copyWith(fontFamily: 'Poppins'),
        titleMedium: bodyTheme.titleMedium?.copyWith(fontFamily: 'Poppins'),
        titleSmall: bodyTheme.titleSmall?.copyWith(fontFamily: 'Poppins'),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
