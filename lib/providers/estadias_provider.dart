import 'package:flutter/foundation.dart';

import '../db/db_helper.dart';
import '../models/estadia.dart';
import '../services/calculo_ganancia_service.dart';

class EstadiasProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  final CalculoGananciaService _calculoService;

  EstadiasProvider({CalculoGananciaService? calculoService})
      : _calculoService = calculoService ?? CalculoGananciaService();

  DateTime mesActual = DateTime(DateTime.now().year, DateTime.now().month);
  List<Estadia> estadias = [];
  DesgloseGanancia? desglose;
  double ocupacionPorcentaje = 0;
  bool cargando = false;

  Future<void> cargarMes(DateTime mes, {int numeroHabitaciones = 1}) async {
    cargando = true;
    notifyListeners();
    mesActual = DateTime(mes.year, mes.month);
    final desde = DateTime(mes.year, mes.month, 1);
    final hasta = DateTime(mes.year, mes.month + 1, 0, 23, 59, 59);
    estadias = await _db.obtenerEstadias(desde: desde, hasta: hasta);
    desglose = await _calculoService.calcularParaPeriodo(estadias);
    ocupacionPorcentaje = _calculoService.calcularOcupacionMes(
      estadiasDelMes: estadias,
      numeroHabitaciones: numeroHabitaciones == 0 ? 1 : numeroHabitaciones,
      mesReferencia: mes,
    );
    cargando = false;
    notifyListeners();
  }

  Future<void> mesAnterior({int numeroHabitaciones = 1}) {
    return cargarMes(
      DateTime(mesActual.year, mesActual.month - 1),
      numeroHabitaciones: numeroHabitaciones,
    );
  }

  Future<void> mesSiguiente({int numeroHabitaciones = 1}) {
    return cargarMes(
      DateTime(mesActual.year, mesActual.month + 1),
      numeroHabitaciones: numeroHabitaciones,
    );
  }

  Future<void> crear(Estadia estadia) async {
    final solapa = await _db.existeSolapamiento(
      habitacionId: estadia.habitacionId,
      entrada: estadia.fechaEntrada,
      salida: estadia.fechaSalida,
    );
    if (solapa) {
      throw Exception('Ya existe una estadía en esa habitación para esas fechas.');
    }
    await _db.crearEstadia(estadia);
    await cargarMes(mesActual);
  }

  Future<void> actualizar(Estadia estadia) async {
    final solapa = await _db.existeSolapamiento(
      habitacionId: estadia.habitacionId,
      entrada: estadia.fechaEntrada,
      salida: estadia.fechaSalida,
      excluirEstadiaId: estadia.id,
    );
    if (solapa) {
      throw Exception('Ya existe una estadía en esa habitación para esas fechas.');
    }
    await _db.actualizarEstadia(estadia);
    await cargarMes(mesActual);
  }

  Future<void> cancelar(Estadia estadia) async {
    await _db.actualizarEstadia(estadia.copyWith(estadoEstadia: EstadoEstadia.cancelada));
    await cargarMes(mesActual);
  }

  Future<void> eliminar(int id) async {
    await _db.eliminarEstadia(id);
    await cargarMes(mesActual);
  }
}