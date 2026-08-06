enum Nacionalidad { nacional, extranjero }
enum Moneda { cup, usd, eur }

Nacionalidad nacionalidadFromString(String value) {
  return Nacionalidad.values.firstWhere(
    (n) => n.name == value,
    orElse: () => Nacionalidad.nacional,
  );
}

Moneda monedaFromString(String value) {
  return Moneda.values.firstWhere(
    (m) => m.name == value,
    orElse: () => Moneda.cup,
  );
}

class Estadia {
  final int? id;
  final int habitacionId;
  final DateTime fechaEntrada;
  final DateTime fechaSalida;
  final int numeroHuespedes;
  final Nacionalidad nacionalidad;
  final double precioCobrado;
  final Moneda monedaCobro;
  final String? notas;

  const Estadia({
    this.id,
    required this.habitacionId,
    required this.fechaEntrada,
    required this.fechaSalida,
    required this.numeroHuespedes,
    required this.nacionalidad,
    required this.precioCobrado,
    required this.monedaCobro,
    this.notas,
  });

  /// Noches de la estadía. Una entrada y salida el mismo día cuenta como
  /// mínimo 1 noche para que el cálculo de gastos no quede en cero.
  int get noches {
    final diff = fechaSalida.difference(fechaEntrada).inDays;
    return diff > 0 ? diff : 1;
  }

  Estadia copyWith({
    int? id,
    int? habitacionId,
    DateTime? fechaEntrada,
    DateTime? fechaSalida,
    int? numeroHuespedes,
    Nacionalidad? nacionalidad,
    double? precioCobrado,
    Moneda? monedaCobro,
    String? notas,
  }) {
    return Estadia(
      id: id ?? this.id,
      habitacionId: habitacionId ?? this.habitacionId,
      fechaEntrada: fechaEntrada ?? this.fechaEntrada,
      fechaSalida: fechaSalida ?? this.fechaSalida,
      numeroHuespedes: numeroHuespedes ?? this.numeroHuespedes,
      nacionalidad: nacionalidad ?? this.nacionalidad,
      precioCobrado: precioCobrado ?? this.precioCobrado,
      monedaCobro: monedaCobro ?? this.monedaCobro,
      notas: notas ?? this.notas,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitacion_id': habitacionId,
      'fecha_entrada': fechaEntrada.toIso8601String(),
      'fecha_salida': fechaSalida.toIso8601String(),
      'numero_huespedes': numeroHuespedes,
      'nacionalidad': nacionalidad.name,
      'precio_cobrado': precioCobrado,
      'moneda_cobro': monedaCobro.name,
      'notas': notas,
    };
  }

  factory Estadia.fromMap(Map<String, dynamic> map) {
    return Estadia(
      id: map['id'] as int?,
      habitacionId: map['habitacion_id'] as int,
      fechaEntrada: DateTime.parse(map['fecha_entrada'] as String),
      fechaSalida: DateTime.parse(map['fecha_salida'] as String),
      numeroHuespedes: map['numero_huespedes'] as int,
      nacionalidad: nacionalidadFromString(map['nacionalidad'] as String),
      precioCobrado: (map['precio_cobrado'] as num).toDouble(),
      monedaCobro: monedaFromString(map['moneda_cobro'] as String),
      notas: map['notas'] as String?,
    );
  }
}
