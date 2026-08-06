class CostoFijo {
  final int? id;
  final String nombre;
  final double montoMensual;

  const CostoFijo({
    this.id,
    required this.nombre,
    required this.montoMensual,
  });

  CostoFijo copyWith({int? id, String? nombre, double? montoMensual}) {
    return CostoFijo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      montoMensual: montoMensual ?? this.montoMensual,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'monto_mensual': montoMensual,
    };
  }

  factory CostoFijo.fromMap(Map<String, dynamic> map) {
    return CostoFijo(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      montoMensual: (map['monto_mensual'] as num).toDouble(),
    );
  }
}
