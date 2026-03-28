import 'package:flutter/material.dart';

/// Warm brown + cream palette (no glow / neon).
///
/// - Dark brown `#5A3E36` — text, emphasis
/// - Medium brown `#8B5E3C` — primary actions
/// - Beige `#D7BFAE` — surfaces / chips
/// - Cream `#F5EDE4` — scaffold background
class AppTheme {
  static const Color darkBrown = Color(0xFF5A3E36);
  static const Color mediumBrown = Color(0xFF8B5E3C);
  static const Color beige = Color(0xFFD7BFAE);
  static const Color cream = Color(0xFFF5EDE4);

  /// Chart: income vs expense (same palette, two weights).
  static const Color chartIncome = mediumBrown;
  static const Color chartExpense = darkBrown;

  /// Semantics used across screens (no separate accent colors).
  static const Color positiveMoney = darkBrown;
  static const Color quickExpenseAccent = mediumBrown;

  /// “Alert” tone staying inside the brown family.
  static const Color spendStress = Color(0xFF6B4538);

  static ThemeData light() {
    final scheme = ColorScheme.light(
      brightness: Brightness.light,
      primary: mediumBrown,
      onPrimary: cream,
      secondary: darkBrown,
      onSecondary: cream,
      surface: beige,
      onSurface: darkBrown,
      onSurfaceVariant: darkBrown.withValues(alpha: 0.75),
      tertiary: darkBrown,
      onTertiary: cream,
      error: spendStress,
      onError: cream,
      surfaceContainerHighest: Color.lerp(beige, cream, 0.35)!,
      outline: darkBrown.withValues(alpha: 0.28),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: cream,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: cream,
        foregroundColor: darkBrown,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: darkBrown,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Color.lerp(beige, cream, 0.2)!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Color.lerp(cream, beige, 0.4)!,
        indicatorColor: mediumBrown.withValues(alpha: 0.18),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 68,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: mediumBrown, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: mediumBrown,
        foregroundColor: cream,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: mediumBrown,
          foregroundColor: cream,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: darkBrown.withValues(alpha: 0.12),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkBrown,
        contentTextStyle: const TextStyle(color: cream),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
