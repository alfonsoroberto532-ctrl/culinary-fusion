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
  final double costoCompra;
  final double cantidadRinde;
  final TipoConsumo tipoConsumo;
  final double cantidadConsumoEstandar;
  final bool activo;

  const Insumo({
    this.id,
    required this.nombre,
    required this.costoCompra,
    required this.cantidadRinde,
    required this.tipoConsumo,
    required this.cantidadConsumoEstandar,
    this.activo = true,
  });

  double get costoUnitario => cantidadRinde > 0 ? costoCompra / cantidadRinde : 0;

  Insumo copyWith({
    int? id,
    String? nombre,
    double? costoCompra,
    double? cantidadRinde,
    TipoConsumo? tipoConsumo,
    double? cantidadConsumoEstandar,
    bool? activo,
  }) {
    return Insumo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      costoCompra: costoCompra ?? this.costoCompra,
      cantidadRinde: cantidadRinde ?? this.cantidadRinde,
      tipoConsumo: tipoConsumo ?? this.tipoConsumo,
      cantidadConsumoEstandar: cantidadConsumoEstandar ?? this.cantidadConsumoEstandar,
      activo: activo ?? this.activo,
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
      'activo': activo ? 1 : 0,
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
      activo: (map['activo'] as int? ?? 1) == 1,
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