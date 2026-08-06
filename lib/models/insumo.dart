/// Cómo se consume un insumo: por cada huésped en la estadía completa,
/// o por cada noche que dura la estadía (independiente del número de huéspedes).
enum TipoConsumo { porHuespedEstadia, porNocheHabitacion }

TipoConsumo tipoConsumoFromString(String value) {
  return TipoConsumo.values.firstWhere(
    (t) => t.name == value,
    orElse: () => TipoConsumo.porHuespedEstadia,
  );
}

class Insumo {
  final int? id;
  final String nombre;

  /// Precio pagado por el lote/paquete comprado (ej. 3.50).
  final double costoCompra;

  /// Cuántas unidades rinde ese lote (ej. 12 jabones por paquete).
  /// costoUnitario = costoCompra / cantidadRinde.
  final double cantidadRinde;

  final TipoConsumo tipoConsumo;

  /// Cuánto se consume por huésped (si tipoConsumo es porHuespedEstadia)
  /// o por noche (si es porNocheHabitacion). Ej: 1 unidad, o 30 (gramos).
  final double cantidadConsumoEstandar;

  const Insumo({
    this.id,
    required this.nombre,
    required this.costoCompra,
    required this.cantidadRinde,
    required this.tipoConsumo,
    required this.cantidadConsumoEstandar,
  });

  double get costoUnitario => cantidadRinde > 0 ? costoCompra / cantidadRinde : 0;

  Insumo copyWith({
    int? id,
    String? nombre,
    double? costoCompra,
    double? cantidadRinde,
    TipoConsumo? tipoConsumo,
    double? cantidadConsumoEstandar,
  }) {
    return Insumo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      costoCompra: costoCompra ?? this.costoCompra,
      cantidadRinde: cantidadRinde ?? this.cantidadRinde,
      tipoConsumo: tipoConsumo ?? this.tipoConsumo,
      cantidadConsumoEstandar: cantidadConsumoEstandar ?? this.cantidadConsumoEstandar,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'costo_compra': costoCompra,
      'cantidad_rinde': cantidadRinde,
      'tipo_consumo': tipoConsumo.name,
      'cantidad_consumo_estandar': cantidadConsumoEstandar,
    };
  }

  factory Insumo.fromMap(Map<String, dynamic> map) {
    return Insumo(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      costoCompra: (map['costo_compra'] as num).toDouble(),
      cantidadRinde: (map['cantidad_rinde'] as num).toDouble(),
      tipoConsumo: tipoConsumoFromString(map['tipo_consumo'] as String),
      cantidadConsumoEstandar: (map['cantidad_consumo_estandar'] as num).toDouble(),
    );
  }
}

class HistorialPrecioInsumo {
  final int? id;
  final int insumoId;
  final double precioAnterior;
  final DateTime fechaCambio;

  const HistorialPrecioInsumo({
    this.id,
    required this.insumoId,
    required this.precioAnterior,
    required this.fechaCambio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'insumo_id': insumoId,
      'precio_anterior': precioAnterior,
      'fecha_cambio': fechaCambio.toIso8601String(),
    };
  }

  factory HistorialPrecioInsumo.fromMap(Map<String, dynamic> map) {
    return HistorialPrecioInsumo(
      id: map['id'] as int?,
      insumoId: map['insumo_id'] as int,
      precioAnterior: (map['precio_anterior'] as num).toDouble(),
      fechaCambio: DateTime.parse(map['fecha_cambio'] as String),
    );
  }
}
