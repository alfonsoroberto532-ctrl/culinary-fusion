class CostoFijo {
  final int? id;
  final String nombre;
  final double montoMensual;
  final bool activo;

  const CostoFijo({
    this.id,
    required this.nombre,
    required this.montoMensual,
    this.activo = true,
  });

  CostoFijo copyWith({int? id, String? nombre, double? montoMensual, bool? activo}) {
    return CostoFijo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      montoMensual: montoMensual ?? this.montoMensual,
      activo: activo ?? this.activo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'monto_mensual': montoMensual,
      'activo': activo ? 1 : 0,
    };
  }

  factory CostoFijo.fromMap(Map<String, dynamic> map) {
    return CostoFijo(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      montoMensual: (map['monto_mensual'] as num).toDouble(),
      activo: (map['activo'] as int? ?? 1) == 1,
    );
  }
}