import 'package:flutter/material.dart';
import '../models/room.dart';

/// Paleta de colores de VaraNova Hostal — extraída de Color.kt/Theme.kt
/// del proyecto original (Google AI Studio / Kotlin-Compose) para mantener
/// exactamente el mismo tema visual en la versión Flutter/Dart.
class AppColors {
  AppColors._();

  // ---- Colores primarios de marca ----
  static const Color tealPrimary = Color(0xFF0284C7);
  static const Color tealPrimaryContainer = Color(0xFFE0F2FE);
  static const Color amberSecondary = Color(0xFFD97706);
  static const Color amberSecondaryContainer = Color(0xFFFEF3C7);
  static const Color emeraldTertiary = Color(0xFF059669);
  static const Color emeraldTertiaryContainer = Color(0xFFD1FAE5);

  // ---- Fondo y superficies (slate) ----
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color slateSurfaceVariant = Color(0xFFE2E8F0);
  static const Color slateOnSurfaceVariant = Color(0xFF64748B);
  static const Color slateDark = Color(0xFF0F172A);

  // ---- Estados de habitación ----
  static const Color statusAvailable = Color(0xFF059669); // Emerald
  static const Color statusReserved = Color(0xFFD97706); // Amber
  static const Color statusOccupied = Color(0xFFDC2626); // Rose
  static const Color statusCleaning = Color(0xFF7C3AED); // Violeta
  static const Color statusMaintenance = Color(0xFFEA580C); // Naranja

  // ---- Alertas ----
  static const Color alertWarning = Color(0xFFD97706);
  static const Color alertCritical = Color(0xFFDC2626);
  static const Color alertSuccess = Color(0xFF059669);

  /// Color asociado a un estado de habitación (RoomStatus.*)
  static Color statusColor(String status) {
    switch (status) {
      case RoomStatus.available:
        return statusAvailable;
      case RoomStatus.reserved:
        return statusReserved;
      case RoomStatus.occupied:
        return statusOccupied;
      case RoomStatus.cleaningPending:
        return statusCleaning.withValues(alpha: 0.75);
      case RoomStatus.cleaning:
        return statusCleaning;
      case RoomStatus.maintenance:
        return statusMaintenance;
      default:
        return slateOnSurfaceVariant;
    }
  }

  /// Etiqueta en español para un estado de habitación (RoomStatus.*)
  static String statusLabel(String status) {
    switch (status) {
      case RoomStatus.available:
        return 'Disponible';
      case RoomStatus.reserved:
        return 'Reservada';
      case RoomStatus.occupied:
        return 'Ocupada';
      case RoomStatus.cleaningPending:
        return 'Por Limpiar';
      case RoomStatus.cleaning:
        return 'En Limpieza';
      case RoomStatus.maintenance:
        return 'Mantenimiento';
      default:
        return status;
    }
  }
}
