import '../db/db_helper.dart';
import '../models/configuracion.dart';
import '../models/estadia.dart';
import '../models/insumo.dart';

/// Desglose de ganancia de una estadía puntual, en la moneda base configurada.
class DesgloseGanancia {
  final double ingresoBruto;
  final double costoInsumos;
  final double costoFijoProrrateado;
  final double gananciaReal;

  const DesgloseGanancia({
    required this.ingresoBruto,
    required this.costoInsumos,
    required this.costoFijoProrrateado,
    required this.gananciaReal,
  });

  /// Porcentaje de margen real. 0 si el ingreso bruto es 0 (evita división por cero).
  double get margenRealPorcentaje =>
      ingresoBruto > 0 ? (gananciaReal / ingresoBruto) * 100 : 0;
}

class CalculoGananciaService {
  final DBHelper dbHelper;

  CalculoGananciaService({DBHelper? dbHelper}) : dbHelper = dbHelper ?? DBHelper.instance;

  double convertirAMonedaBase(double monto, Moneda moneda, Configuracion config) {
    switch (moneda) {
      case Moneda.usd:
        return monto * config.tasaCambioUsdACup;
      case Moneda.eur:
        return monto * config.tasaCambioEurACup;
      case Moneda.cup:
        return monto;
    }
  }

  /// Costo total de insumos consumidos en una estadía, según el catálogo actual.
  double calcularCostoInsumos(Estadia estadia, List<Insumo> insumos) {
    double total = 0;
    for (final insumo in insumos) {
      final cantidad = insumo.tipoConsumo == TipoConsumo.porHuespedEstadia
          ? insumo.cantidadConsumoEstandar * estadia.numeroHuespedes
          : insumo.cantidadConsumoEstandar * estadia.noches;
      total += insumo.costoUnitario * cantidad;
    }
    return total;
  }

  /// Costo fijo mensual total dividido entre los días del mes de la fecha de
  /// entrada, multiplicado por las noches de la estadía.
  double calcularCostoFijoProrrateado({
    required double totalCostosFijosMensual,
    required DateTime fechaEntrada,
    required int noches,
  }) {
    final diasDelMes = DateTime(fechaEntrada.year, fechaEntrada.month + 1, 0).day;
    if (diasDelMes == 0) return 0;
    return (totalCostosFijosMensual / diasDelMes) * noches;
  }

  /// Calcula el desglose completo de ganancia para una estadía, consultando
  /// insumos, costos fijos y configuración de tasas de cambio actuales.
  Future<DesgloseGanancia> calcularParaEstadia(Estadia estadia) async {
    final config = await dbHelper.obtenerConfiguracion();
    final insumos = await dbHelper.obtenerInsumos();
    final costosFijos = await dbHelper.obtenerCostosFijos();

    final ingresoBruto = convertirAMonedaBase(estadia.precioCobrado, estadia.monedaCobro, config);
    final costoInsumos = calcularCostoInsumos(estadia, insumos);
    final totalCostosFijosMensual = costosFijos.fold(0.0, (sum, c) => sum + c.montoMensual);
    final costoFijoProrrateado = calcularCostoFijoProrrateado(
      totalCostosFijosMensual: totalCostosFijosMensual,
      fechaEntrada: estadia.fechaEntrada,
      noches: estadia.noches,
    );
    final gananciaReal = ingresoBruto - costoInsumos - costoFijoProrrateado;

    return DesgloseGanancia(
      ingresoBruto: ingresoBruto,
      costoInsumos: costoInsumos,
      costoFijoProrrateado: costoFijoProrrateado,
      gananciaReal: gananciaReal,
    );
  }

  /// Suma el desglose de todas las estadías de un período (ej. un mes),
  /// para alimentar el dashboard principal.
  Future<DesgloseGanancia> calcularParaPeriodo(List<Estadia> estadias) async {
    double ingresoBruto = 0, costoInsumos = 0, costoFijoProrrateado = 0, gananciaReal = 0;
    for (final estadia in estadias) {
      final d = await calcularParaEstadia(estadia);
      ingresoBruto += d.ingresoBruto;
      costoInsumos += d.costoInsumos;
      costoFijoProrrateado += d.costoFijoProrrateado;
      gananciaReal += d.gananciaReal;
    }
    return DesgloseGanancia(
      ingresoBruto: ingresoBruto,
      costoInsumos: costoInsumos,
      costoFijoProrrateado: costoFijoProrrateado,
      gananciaReal: gananciaReal,
    );
  }

  /// % de ocupación del mes: noches ocupadas (según estadías registradas que
  /// caen dentro del mes) sobre noches disponibles (habitaciones × días del mes).
  double calcularOcupacionMes({
    required List<Estadia> estadiasDelMes,
    required int numeroHabitaciones,
    required DateTime mesReferencia,
  }) {
    final diasDelMes = DateTime(mesReferencia.year, mesReferencia.month + 1, 0).day;
    final nochesDisponibles = diasDelMes * numeroHabitaciones;
    if (nochesDisponibles == 0) return 0;
    final nochesOcupadas = estadiasDelMes.fold(0, (sum, e) => sum + e.noches);
    return (nochesOcupadas / nochesDisponibles) * 100;
  }
}
