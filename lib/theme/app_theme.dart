import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tema Material de VaraNova Hostal, equivalente al Theme.kt del proyecto
/// original en Jetpack Compose.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.tealPrimary,
      brightness: Brightness.light,
      primary: AppColors.tealPrimary,
      primaryContainer: AppColors.tealPrimaryContainer,
      secondary: AppColors.amberSecondary,
      secondaryContainer: AppColors.amberSecondaryContainer,
      tertiary: AppColors.emeraldTertiary,
      tertiaryContainer: AppColors.emeraldTertiaryContainer,
      surface: AppColors.surface,
      error: AppColors.alertCritical,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.slateDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.slateDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.slateSurfaceVariant),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.tealPrimary,
        unselectedItemColor: AppColors.slateOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5),
        elevation: 8,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.tealPrimary,
        foregroundColor: Colors.white,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.tealPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tealPrimary,
          side: const BorderSide(color: AppColors.tealPrimary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.tealPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slateSurfaceVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slateSurfaceVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.tealPrimary, width: 1.6),
        ),
        labelStyle: const TextStyle(color: AppColors.slateOnSurfaceVariant),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.slateSurfaceVariant.withValues(alpha: 0.5),
        selectedColor: AppColors.tealPrimaryContainer,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.slateSurfaceVariant,
        thickness: 1,
        space: 1,
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.tealPrimary,
        unselectedLabelColor: AppColors.slateOnSurfaceVariant,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        indicatorColor: AppColors.tealPrimary,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.slateDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
