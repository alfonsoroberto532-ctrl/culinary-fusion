import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/enums.dart';

/// Paleta y tokens visuales centralizados de Culinary Fusion.
/// Inspirada en el estilo cálido (crema/naranja) + teal de la referencia:
/// tarjetas redondeadas, sombras suaves, gradientes en los elementos
/// destacados (app bar, generadores, encabezados).
class AppColors {
  AppColors._();

  // Marca
  static const Color primary = Color(0xFFFF8A3D);
  static const Color primaryDark = Color(0xFFE86A2E);
  static const Color secondary = Color(0xFF1F8A7A);
  static const Color secondaryDark = Color(0xFF146B5E);

  // Acento / feedback
  static const Color gold = Color(0xFFFFC94D);
  static const Color goldDark = Color(0xFFE0A72E);
  static const Color success = Color(0xFF3FB871);

  // Texto
  static const Color textDark = Color(0xFF3E2E1F);
  static const Color textMuted = Color(0xFF9C8C77);

  // Superficies
  static const Color background = Color(0xFFFFF6EC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFFBF3E7);

  // Gradientes
  static const List<Color> heroGradient = [secondary, primary];
  static const List<Color> tealGradient = [Color(0xFF2BB3A3), secondaryDark];
}

/// Colores por rareza, usados en tiles del tablero, libro de recetas y
/// árbol gastronómico para dar lectura visual instantánea al valor de
/// un ingrediente/receta.
extension RarityColor on Rarity {
  Color get color {
    switch (this) {
      case Rarity.comun:
        return const Color(0xFF9C8C77);
      case Rarity.raro:
        return const Color(0xFF4C9BE8);
      case Rarity.epico:
        return const Color(0xFFA65EDB);
      case Rarity.mitico:
        return const Color(0xFFE85CA0);
      case Rarity.legendario:
        return const Color(0xFFE0A72E);
    }
  }

  Color get colorSoft {
    switch (this) {
      case Rarity.comun:
        return const Color(0xFFF2EEE6);
      case Rarity.raro:
        return const Color(0xFFE7F1FC);
      case Rarity.epico:
        return const Color(0xFFF3E9FC);
      case Rarity.mitico:
        return const Color(0xFFFDEAF4);
      case Rarity.legendario:
        return const Color(0xFFFFF3D6);
    }
  }
}

/// Tarjeta con esquinas redondeadas, sombra suave y borde sutil. Es la
/// decoración base reutilizada en casi toda la app (pedidos, recetas,
/// misiones, elementos del restaurante...).
BoxDecoration softCardDecoration({
  double radius = 16,
  Color? color,
  Color? borderColor,
}) {
  return BoxDecoration(
    color: color ?? AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor ?? const Color(0xFFF0E1C4)),
    boxShadow: const [
      BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 3)),
    ],
  );
}

/// Tarjeta con gradiente diagonal (usada en encabezados destacados:
/// app bar, tarjetas de generador, banner del restaurante).
BoxDecoration gradientCardDecoration(List<Color> colors, {double radius = 16}) {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(color: colors.last.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4)),
    ],
  );
}

/// ThemeData de Material 3 con la paleta y tipografía redondeada
/// (Baloo 2 para títulos, Nunito para cuerpo de texto).
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
    );

    final textTheme = GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
      titleLarge: GoogleFonts.baloo2(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark),
      titleMedium: GoogleFonts.baloo2(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark),
      titleSmall: GoogleFonts.baloo2(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
      bodyLarge: GoogleFonts.nunito(fontSize: 15, color: AppColors.textDark),
      bodyMedium: GoogleFonts.nunito(fontSize: 13.5, color: AppColors.textDark),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.baloo2(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
