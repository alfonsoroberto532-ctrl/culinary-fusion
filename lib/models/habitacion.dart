class Habitacion {
  final int? id;
  final String nombre;
  final int capacidadMaxima;
  final double precioBaseNoche;

  /// Baja lógica: una habitación inactiva no aparece para nuevas estadías,
  /// pero conserva su histórico intacto en los reportes.
  final bool activo;

  const Habitacion({
    this.id,
    required this.nombre,
    required this.capacidadMaxima,
    required this.precioBaseNoche,
    this.activo = true,
  });

  Habitacion copyWith({
    int? id,
    String? nombre,
    int? capacidadMaxima,
    double? precioBaseNoche,
    bool? activo,
  }) {
    return Habitacion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      capacidadMaxima: capacidadMaxima ?? this.capacidadMaxima,
      precioBaseNoche: precioBaseNoche ?? this.precioBaseNoche,
      activo: activo ?? this.activo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'capacidad_maxima': capacidadMaxima,
      'precio_base_noche': precioBaseNoche,
      'activo': activo ? 1 : 0,
    };
  }

  factory Habitacion.fromMap(Map<String, dynamic> map) {
    return Habitacion(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      capacidadMaxima: map['capacidad_maxima'] as int,
      precioBaseNoche: (map['precio_base_noche'] as num).toDouble(),
      activo: (map['activo'] as int? ?? 1) == 1,
    );
  }
}