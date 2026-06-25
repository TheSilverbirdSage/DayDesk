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
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkCardBackground = Color(0xFF1F2937);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color pageBackground(BuildContext context) =>
      isDark(context) ? darkBackground : background;

  static Color surface(BuildContext context) =>
      isDark(context) ? darkCardBackground : cardBackground;

  static Color elevatedSurface(BuildContext context) =>
      isDark(context) ? const Color(0xFF273244) : cardBackground;

  static Color navSurface(BuildContext context) =>
      isDark(context) ? const Color(0xFF172033) : cardBackground;

  static Color primaryText(BuildContext context) =>
      isDark(context) ? darkTextPrimary : textPrimary;

  static Color secondaryText(BuildContext context) =>
      isDark(context) ? darkTextSecondary : textSecondary;

  static Color primaryAccent(BuildContext context) =>
      isDark(context) ? const Color(0xFFB4B5FF) : primary;

  static Color softFill(BuildContext context) =>
      isDark(context) ? const Color(0xFF2C374A) : statBlue;

  static Color divider(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.055);

  static List<BoxShadow> softShadow(BuildContext context) => isDark(context)
      ? []
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ];

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

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final bodyTheme = base.textTheme.apply(
      fontFamily: 'Inter',
      bodyColor: darkTextPrimary,
      displayColor: darkTextPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primary,
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF8B8CF6),
        secondary: const Color(0xFF5EE7B7),
        surface: darkCardBackground,
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
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardBackground,
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
          borderSide: const BorderSide(color: Color(0xFF8B8CF6), width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B8CF6),
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
