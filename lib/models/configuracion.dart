/// Representa la configuración global de la aplicación.
///
/// La configuración se guarda en la base de datos en una tabla especial
/// de llave-valor, donde cada fila es un parámetro de configuración.
class Configuracion {
  /// Tasa de cambio de USD a CUP.
  final double tasaCambioUsdACup;

  /// Tasa de cambio de EUR a CUP.
  final double tasaCambioEurACup;

  /// Moneda base para mostrar los reportes de ganancias.
  final String monedaBase;

  const Configuracion({
    required this.tasaCambioUsdACup,
    required this.tasaCambioEurACup,
    this.monedaBase = 'CUP',
  });

  Map<String, dynamic> toMap() {
    return {
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
