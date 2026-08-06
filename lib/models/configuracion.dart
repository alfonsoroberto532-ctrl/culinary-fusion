class Configuracion {
  final double tasaCambioUsdACup;
  final double tasaCambioEurACup;
  final String monedaBase; // Por ahora siempre 'CUP', pero queda abierto a futuro.

  const Configuracion({
    required this.tasaCambioUsdACup,
    required this.tasaCambioEurACup,
    this.monedaBase = 'CUP',
  });

  Configuracion copyWith({
    double? tasaCambioUsdACup,
    double? tasaCambioEurACup,
    String? monedaBase,
  }) {
    return Configuracion(
      tasaCambioUsdACup: tasaCambioUsdACup ?? this.tasaCambioUsdACup,
      tasaCambioEurACup: tasaCambioEurACup ?? this.tasaCambioEurACup,
      monedaBase: monedaBase ?? this.monedaBase,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': 1, // Fila única de configuración.
      'tasa_cambio_usd_a_cup': tasaCambioUsdACup,
      'tasa_cambio_eur_a_cup': tasaCambioEurACup,
      'moneda_base': monedaBase,
    };
  }

  factory Configuracion.fromMap(Map<String, dynamic> map) {
    return Configuracion(
      tasaCambioUsdACup: (map['tasa_cambio_usd_a_cup'] as num).toDouble(),
      tasaCambioEurACup: (map['tasa_cambio_eur_a_cup'] as num).toDouble(),
      monedaBase: map['moneda_base'] as String? ?? 'CUP',
    );
  }

  /// Valores de referencia iniciales; el dueño los debe ajustar en Configuración
  /// apenas abra la app por primera vez, y actualizarlos cuando cambie el mercado.
  factory Configuracion.porDefecto() {
    return const Configuracion(tasaCambioUsdACup: 380, tasaCambioEurACup: 400);
  }
}
hjgsdjagdajgdjagdjasdgja