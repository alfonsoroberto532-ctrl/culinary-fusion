import 'package:flutter/foundation.dart';

import '../db/db_helper.dart';
import '../models/costo_fijo.dart';

class CostosFijosProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  List<CostoFijo> costosFijos = [];
  bool cargando = false;

  double get totalMensual => costosFijos.fold(0.0, (s, c) => s + c.montoMensual);

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    costosFijos = await _db.obtenerCostosFijos();
    cargando = false;
    notifyListeners();
  }

  Future<void> crear(CostoFijo c) async {
    await _db.crearCostoFijo(c);
    await cargar();
  }

  Future<void> actualizar(CostoFijo c) async {
    await _db.actualizarCostoFijo(c);
    await cargar();
  }

  Future<void> desactivar(int id) async {
    await _db.desactivarCostoFijo(id);
    await cargar();
  }
}