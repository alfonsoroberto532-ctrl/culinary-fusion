# VaraNova Hostal — Flutter / Dart

Versión Flutter/Dart del proyecto original (Google AI Studio / Kotlin-Compose),
migrada siguiendo el mismo patrón arquitectónico que **VaraNova Restaurante** y
**VaraNova Gestión**: SQLite offline-first con `DBHelper` singleton,
repositorios por dominio, y pantallas Material 3 con el tema Teal/Ámbar/Esmeralda
original.

## Cómo abrir esto en Firebase Studio (idx.google.com)

Este paquete solo trae `lib/`, `pubspec.yaml` y archivos de configuración —
**no** trae las carpetas nativas (`android/`, `ios/`, `web/`, etc.), porque esas
las genera el propio entorno. Pasos:

1. Crea un proyecto Flutter nuevo y vacío en Firebase Studio (o `flutter create varanova_hostal` en la terminal integrada).
2. Reemplaza la carpeta `lib/` generada por la de este paquete, y copia también `pubspec.yaml`, `analysis_options.yaml` y `.gitignore`.
3. Corre:
   ```bash
   flutter pub get
   flutter run
   ```
4. La base de datos SQLite se crea automáticamente en el primer arranque (`_onCreate` en `lib/db/db_helper.dart`), con 2 habitaciones de ejemplo, categorías de gasto y tasas de cambio base (USD/CUP/EUR).

## Estructura del proyecto

```
varanova_hostal/
├── pubspec.yaml
├── analysis_options.yaml
├── .gitignore
└── lib/
    ├── main.dart                        # Punto de entrada, MaterialApp + tema
    │
    ├── theme/
    │   ├── app_colors.dart              # Paleta Teal/Ámbar/Esmeralda + colores de estado
    │   └── app_theme.dart               # ThemeData Material 3 (equivalente a Theme.kt)
    │
    ├── models/                          # Entidades de datos (equivalentes a las @Entity de Room)
    │   ├── room.dart                    # Room, RoomStatus, RoomType
    │   ├── guest.dart                   # Guest
    │   ├── reservation.dart             # Reservation, Payment, ReservationStatus, ReservationWithDetails
    │   ├── expense.dart                 # Expense, ExpenseCategory
    │   ├── supply.dart                  # SupplyItem, InventoryMovement, InventoryMovementType
    │   ├── operations.dart              # CleaningRecord, MaintenanceRecord, sus estados/prioridades
    │   └── exchange_rate.dart           # ExchangeRate
    │
    ├── db/
    │   └── db_helper.dart               # Singleton SQLite: esquema, índices, foreign keys, seed inicial, audit log
    │
    ├── repositories/                    # Toda la lógica de negocio y acceso a datos
    │   ├── room_repository.dart
    │   ├── guest_repository.dart
    │   ├── reservation_repository.dart  # Disponibilidad, check-in/out, pagos, cancelación
    │   ├── finance_repository.dart      # Resumen financiero, series diarias, gastos por categoría, tasas de cambio
    │   ├── supply_repository.dart       # Movimientos de inventario que ajustan stock
    │   └── operations_repository.dart   # Limpieza y mantenimiento
    │
    ├── screens/
    │   ├── main_shell.dart              # Navegación inferior (5 tabs)
    │   ├── dashboard_screen.dart        # Panel inteligente: ocupación, finanzas del día, alertas
    │   ├── rooms_screen.dart + room_form_sheet.dart
    │   ├── reservations_screen.dart + reservation_form_sheet.dart + reservation_detail_screen.dart
    │   ├── guests_screen.dart + guest_form_sheet.dart
    │   ├── finances_screen.dart + expense_form_sheet.dart
    │   ├── supplies_screen.dart + supply_form_sheet.dart + movement_dialog.dart
    │   ├── operations_screen.dart       # NUEVO — tabs Limpieza/Mantenimiento + formulario de incidencia
    │   ├── statistics_screen.dart       # NUEVO — gráficas con fl_chart (ingresos/gastos, ocupación, gastos por categoría)
    │   ├── settings_screen.dart         # NUEVO — gestión de tasas de cambio
    │   └── more_screen.dart             # Menú "Más" que enlaza a Huéspedes/Suministros/Operaciones/Estadísticas/Configuración
    │
    └── widgets/                         # Componentes reutilizables
        ├── stat_card.dart               # Tarjeta de métrica con ícono
        ├── empty_state.dart             # Estado vacío ilustrado
        └── status_badge.dart            # Chip de estado con color
```

## Lo que se completó en esta entrega

- **`theme/app_colors.dart` y `theme/app_theme.dart`** — antes referenciados por
  todas las pantallas pero no existían. Contienen la paleta exacta (`#0284C7`
  Teal, `#D97706` Ámbar, `#059669` Esmeralda, `#F8FAFC` fondo) y los colores de
  estado de habitación/alertas, más `AppColors.statusColor()` /
  `AppColors.statusLabel()` usados por `rooms_screen.dart` y el dashboard.
- **`screens/operations_screen.dart`** — pantalla con `TabBar` (Limpieza /
  Mantenimiento). La pestaña de Limpieza muestra habitaciones pendientes con
  acciones "Iniciar" / "Completar" y el historial reciente. La de
  Mantenimiento permite filtrar por estado, marcar "En Reparación", resolver
  incidencias (con costo y técnico), y un formulario modal (`showMaintenanceFormSheet`)
  para reportar nuevas incidencias con selector de habitación y prioridad.
- **`screens/statistics_screen.dart`** — usa `fl_chart` para: barras de
  ingresos vs. gastos de los últimos 7/14/30 días, gráfica de pastel de
  ocupación por estado de habitación, y barras de gastos por categoría. Se
  agregaron dos métodos nuevos a `finance_repository.dart`
  (`getDailySeries`, `getExpensesByCategory`) para alimentar estas gráficas.
- **`screens/settings_screen.dart`** — listado y edición de tasas de cambio
  (USD es la moneda primaria fija en 1.0; se pueden agregar/editar CUP, EUR,
  etc.), más una sección "Acerca de".

Todo el resto del código (modelos, `db_helper.dart`, repositorios y las demás
pantallas) es el que ya habías avanzado — solo se reorganizó en la estructura
de carpetas `models/ db/ repositories/ screens/ theme/ widgets/` que los
propios `import` de esos archivos ya esperaban.

## Notas técnicas

- Offline-first, sin backend: todo vive en SQLite local (`sqflite`), igual que
  VaraNova Restaurante/Gestión.
- `DBHelper` usa versión de esquema `1`; si necesitas migrar el esquema más
  adelante, sube `_dbVersion` y agrega la lógica en `onUpgrade`.
- Dependencias clave en `pubspec.yaml`: `sqflite`, `path`, `path_provider`,
  `intl`, `fl_chart`.