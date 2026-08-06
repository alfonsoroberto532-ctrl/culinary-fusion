class Habitacion {
  final int? id;
  final String nombre;
  final int capacidadMaxima;
  final double precioBaseNoche;

  const Habitacion({
    this.id,
    required this.nombre,
    required this.capacidadMaxima,
    required this.precioBaseNoche,
  });

  Habitacion copyWith({
    int? id,
    String? nombre,
    int? capacidadMaxima,
    double? precioBaseNoche,
  }) {
    return Habitacion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      capacidadMaxima: capacidadMaxima ?? this.capacidadMaxima,
      precioBaseNoche: precioBaseNoche ?? this.precioBaseNoche,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'capacidad_maxima': capacidadMaxima,
      'precio_base_noche': precioBaseNoche,
    };
  }

  factory Habitacion.fromMap(Map<String, dynamic> map) {
    return Habitacion(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      capacidadMaxima: map['capacidad_maxima'] as int,
      precioBaseNoche: (map['precio_base_noche'] as num).toDouble(),
    );
  }
}
