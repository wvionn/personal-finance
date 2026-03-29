import 'package:flutter/material.dart';

/// Dark brown neon theme matching the provided exact design
class AppTheme {
  static const Color darkBrown = Color(0xFF18120F);
  static const Color panel = Color(0xFF2A211D);
  static const Color elevated = Color(0xFF3B2F29);
  
  static const Color textMain = Color(0xFFEFE6DD);
  static const Color textMuted = Color(0xFFA69990);
  
  static const Color neonAmber = Color(0xFFFFB75E); // Bright neon amber
  static const Color mediumBrown = Color(0xFF7A6150);
  
  static const Color borderHighlight = Color(0xFF53443C);

  static const Color spendStress = Color(0xFFFF725E); // Neon red for negative
  static const Color positiveMoney = neonAmber;

  // Quick expense accent (neon amber)
  static const Color quickExpenseAccent = neonAmber;

  // Chart colors
  static const Color chartIncome = Color(0xFF5ECFA0);  // Neon green for income
  static const Color chartExpense = spendStress;        // Neon red for expense

  static const Color cream = Color(0xFFEFE6DD);
  static const Color softCream = Color(0xFF2A211D);

  static ThemeData light() {
    final baseText = ThemeData.dark(useMaterial3: true).textTheme;
    final scheme = const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: neonAmber,
      onPrimary: darkBrown,
      secondary: elevated,
      onSecondary: textMain,
      surface: panel, // card background
      onSurface: textMain,
      onSurfaceVariant: textMuted,
      tertiary: neonAmber,
      onTertiary: darkBrown,
      error: spendStress,
      onError: textMain,
      surfaceContainerHighest: elevated,
      outline: borderHighlight,
      shadow: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      fontFamily: 'Inter', // Try default or Inter
      scaffoldBackgroundColor: darkBrown,
      canvasColor: darkBrown,
      textTheme: baseText.copyWith(
        headlineSmall: baseText.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.25,
          color: textMain,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: textMain,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          color: textMain,
          height: 1.35,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          color: textMain.withValues(alpha: 0.9),
          height: 1.35,
        ),
        labelLarge: baseText.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: textMain,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: darkBrown,
        foregroundColor: textMain,
        shadowColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
          color: textMain,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        color: panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkBrown,
        indicatorColor: elevated,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Wide rounded pill
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.w600);
          }
          return TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: textMain);
          }
          return const IconThemeData(color: textMuted);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 72,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevated.withValues(alpha: 0.25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderHighlight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderHighlight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: neonAmber, width: 2),
        ),
        iconColor: neonAmber,
        prefixIconColor: neonAmber,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: neonAmber,
        foregroundColor: darkBrown,
        elevation: 8,
        focusElevation: 12,
        hoverElevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: neonAmber.withValues(alpha: 0.8), // changed to fit "Simpan" button
          foregroundColor: darkBrown,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textMain,
          side: const BorderSide(color: textMain),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: neonAmber),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return neonAmber;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(darkBrown),
        side: const BorderSide(color: textMuted),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return neonAmber;
          return textMuted;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return neonAmber;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return neonAmber.withValues(alpha: 0.3);
          }
          return panel;
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkBrown,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dividerTheme: const DividerThemeData(color: borderHighlight, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: elevated,
        contentTextStyle: const TextStyle(color: textMain),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
