enum Nacionalidad { nacional, extranjero }
enum Moneda { cup, usd, eur }
enum EstadoPago { pendiente, parcial, pagado }
enum EstadoEstadia { reservada, activa, finalizada, cancelada }

Nacionalidad nacionalidadFromString(String value) => Nacionalidad.values.firstWhere(
      (n) => n.name == value,
      orElse: () => Nacionalidad.nacional,
    );

Moneda monedaFromString(String value) => Moneda.values.firstWhere(
      (m) => m.name == value,
      orElse: () => Moneda.cup,
    );

EstadoPago estadoPagoFromString(String value) => EstadoPago.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoPago.pendiente,
    );

EstadoEstadia estadoEstadiaFromString(String value) => EstadoEstadia.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoEstadia.activa,
    );

extension EstadoPagoLabel on EstadoPago {
  String get etiqueta => switch (this) {
        EstadoPago.pendiente => 'Pendiente',
        EstadoPago.parcial => 'Parcial',
        EstadoPago.pagado => 'Pagado',
      };
}

extension EstadoEstadiaLabel on EstadoEstadia {
  String get etiqueta => switch (this) {
        EstadoEstadia.reservada => 'Reservada',
        EstadoEstadia.activa => 'Activa',
        EstadoEstadia.finalizada => 'Finalizada',
        EstadoEstadia.cancelada => 'Cancelada',
      };
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

  /// Tasa de cambio vigente al momento de crear la estadía (si la moneda no
  /// es la base). Se usa para reportes históricos, ignorando cambios futuros
  /// en la tasa configurada.
  final double? tasaCambioUsada;

  final EstadoPago estadoPago;
  final EstadoEstadia estadoEstadia;
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
    this.tasaCambioUsada,
    this.estadoPago = EstadoPago.pendiente,
    this.estadoEstadia = EstadoEstadia.activa,
    this.notas,
  });

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
    double? tasaCambioUsada,
    EstadoPago? estadoPago,
    EstadoEstadia? estadoEstadia,
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
      tasaCambioUsada: tasaCambioUsada ?? this.tasaCambioUsada,
      estadoPago: estadoPago ?? this.estadoPago,
      estadoEstadia: estadoEstadia ?? this.estadoEstadia,
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
      'tasa_cambio_usada': tasaCambioUsada,
      'estado_pago': estadoPago.name,
      'estado_estadia': estadoEstadia.name,
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
      tasaCambioUsada: (map['tasa_cambio_usada'] as num?)?.toDouble(),
      estadoPago: estadoPagoFromString(map['estado_pago'] as String? ?? 'pendiente'),
      estadoEstadia: estadoEstadiaFromString(map['estado_estadia'] as String? ?? 'activa'),
      notas: map['notas'] as String?,
    );
  }
}