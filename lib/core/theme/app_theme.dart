import 'package:flutter/material.dart';

/// Warm dark-brown + cream palette.
///
/// Balanced for readability and a more premium look:
/// - Dark brown for key UI chrome and highlights
/// - Layered cream surfaces to avoid a flat/washed look
class AppTheme {
  static const Color darkBrown = Color(0xFF34231E);
  static const Color mediumBrown = Color(0xFF564038);
  static const Color beige = Color(0xFFB89D82);
  static const Color cream = Color(0xFFF1E3D3);
  static const Color softCream = Color(0xFFE1CCB4);

  /// Chart: income vs expense (same palette, two weights).
  static const Color chartIncome = mediumBrown;
  static const Color chartExpense = darkBrown;

  /// Semantics used across screens (no separate accent colors).
  static const Color positiveMoney = darkBrown;
  static const Color quickExpenseAccent = darkBrown;

  /// “Alert” tone staying inside the brown family.
  static const Color spendStress = Color(0xFF6B4538);

  static ThemeData light() {
    final baseText = ThemeData.light(useMaterial3: true).textTheme;
    final scheme = ColorScheme.light(
      brightness: Brightness.light,
      primary: darkBrown,
      onPrimary: cream,
      secondary: mediumBrown,
      onSecondary: cream,
      surface: Color.lerp(softCream, beige, 0.35)!,
      onSurface: darkBrown,
      onSurfaceVariant: darkBrown.withValues(alpha: 0.78),
      tertiary: mediumBrown,
      onTertiary: cream,
      error: spendStress,
      onError: cream,
      surfaceContainerHighest: Color.lerp(softCream, beige, 0.58)!,
      outline: darkBrown.withValues(alpha: 0.34),
      shadow: darkBrown.withValues(alpha: 0.25),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: cream,
      canvasColor: cream,
      textTheme: baseText.copyWith(
        headlineSmall: baseText.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.25,
          color: darkBrown,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: darkBrown,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: darkBrown,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          color: darkBrown.withValues(alpha: 0.94),
          height: 1.35,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          color: darkBrown.withValues(alpha: 0.9),
          height: 1.35,
        ),
        labelLarge: baseText.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: darkBrown,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 2,
        scrolledUnderElevation: 3,
        backgroundColor: darkBrown,
        foregroundColor: cream,
        shadowColor: darkBrown.withValues(alpha: 0.45),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: cream,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: darkBrown.withValues(alpha: 0.16),
        color: Color.lerp(softCream, beige, 0.44)!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.42)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkBrown,
        indicatorColor: mediumBrown.withValues(alpha: 0.72),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: cream, fontWeight: FontWeight.w700);
          }
          return TextStyle(color: cream.withValues(alpha: 0.74));
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: cream);
          }
          return IconThemeData(color: cream.withValues(alpha: 0.72));
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 68,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color.lerp(softCream, beige, 0.42),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.55)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.38)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBrown, width: 1.6),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkBrown,
        foregroundColor: cream,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: darkBrown,
          foregroundColor: cream,
          elevation: 0,
          overlayColor: cream.withValues(alpha: 0.08),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkBrown,
          side: BorderSide(color: darkBrown.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: darkBrown),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return darkBrown;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(cream),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return darkBrown;
          return darkBrown.withValues(alpha: 0.55);
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return darkBrown;
          return beige;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkBrown.withValues(alpha: 0.42);
          }
          return darkBrown.withValues(alpha: 0.2);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Color.lerp(softCream, beige, 0.38)!,
        selectedColor: darkBrown,
        disabledColor: Color.lerp(softCream, beige, 0.22)!,
        labelStyle: const TextStyle(color: darkBrown),
        secondaryLabelStyle: const TextStyle(color: cream),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: darkBrown.withValues(alpha: 0.25)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Color.lerp(softCream, beige, 0.3),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Color.lerp(softCream, beige, 0.34),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: darkBrown,
        textColor: darkBrown,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: darkBrown,
        selectionColor: darkBrown.withValues(alpha: 0.22),
        selectionHandleColor: darkBrown,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: darkBrown,
      ),
      dividerTheme: DividerThemeData(color: darkBrown.withValues(alpha: 0.12)),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkBrown,
        contentTextStyle: const TextStyle(color: cream),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
