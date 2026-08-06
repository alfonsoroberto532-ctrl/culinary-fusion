import '../db/db_helper.dart';
import '../models/configuracion.dart';
import '../models/estadia.dart';
import '../models/insumo.dart';

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

  double get margenRealPorcentaje =>
      ingresoBruto > 0 ? (gananciaReal / ingresoBruto) * 100 : 0;
}

class CalculoGananciaService {
  final DBHelper dbHelper;

  CalculoGananciaService({DBHelper? dbHelper}) : dbHelper = dbHelper ?? DBHelper.instance;

  /// [tasaOverride] permite usar la tasa congelada en la estadía en vez de
  /// la tasa vigente hoy en Configuración, para que el histórico no cambie.
  double convertirAMonedaBase(
    double monto,
    Moneda moneda,
    Configuracion config, {
    double? tasaOverride,
  }) {
    switch (moneda) {
      case Moneda.usd:
        return monto * (tasaOverride ?? config.tasaCambioUsdACup);
      case Moneda.eur:
        return monto * (tasaOverride ?? config.tasaCambioEurACup);
      case Moneda.cup:
        return monto;
    }
  }

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

  double calcularCostoFijoProrrateado({
    required double totalCostosFijosMensual,
    required DateTime fechaEntrada,
    required int noches,
  }) {
    final diasDelMes = DateTime(fechaEntrada.year, fechaEntrada.month + 1, 0).day;
    if (diasDelMes == 0) return 0;
    return (totalCostosFijosMensual / diasDelMes) * noches;
  }

  Future<DesgloseGanancia> calcularParaEstadia(Estadia estadia) async {
    final config = await dbHelper.obtenerConfiguracion();
    final insumos = await dbHelper.obtenerInsumos();
    final costosFijos = await dbHelper.obtenerCostosFijos();

    final ingresoBruto = convertirAMonedaBase(
      estadia.precioCobrado,
      estadia.monedaCobro,
      config,
      tasaOverride: estadia.tasaCambioUsada,
    );
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

  /// Suma el desglose de un período. Las estadías canceladas no cuentan
  /// como ingreso ni como costo.
  Future<DesgloseGanancia> calcularParaPeriodo(List<Estadia> estadias) async {
    double ingresoBruto = 0, costoInsumos = 0, costoFijoProrrateado = 0, gananciaReal = 0;
    for (final estadia in estadias) {
      if (estadia.estadoEstadia == EstadoEstadia.cancelada) continue;
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

  double calcularOcupacionMes({
    required List<Estadia> estadiasDelMes,
    required int numeroHabitaciones,
    required DateTime mesReferencia,
  }) {
    final diasDelMes = DateTime(mesReferencia.year, mesReferencia.month + 1, 0).day;
    final nochesDisponibles = diasDelMes * numeroHabitaciones;
    if (nochesDisponibles == 0) return 0;
    final nochesOcupadas = estadiasDelMes
        .where((e) => e.estadoEstadia != EstadoEstadia.cancelada)
        .fold(0, (sum, e) => sum + e.noches);
    return (nochesOcupadas / nochesDisponibles) * 100;
  }
}