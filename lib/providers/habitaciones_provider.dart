import 'package:flutter/foundation.dart';

import '../db/db_helper.dart';
import '../models/habitacion.dart';

class HabitacionesProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  List<Habitacion> habitaciones = [];
  bool cargando = false;

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    habitaciones = await _db.obtenerHabitaciones();
    cargando = false;
    notifyListeners();
  }

  Future<void> crear(Habitacion h) async {
    await _db.crearHabitacion(h);
    await cargar();
  }

  Future<void> actualizar(Habitacion h) async {
    await _db.actualizarHabitacion(h);
    await cargar();
  }

  Future<void> desactivar(int id) async {
    await _db.desactivarHabitacion(id);
    await cargar();
  }
}