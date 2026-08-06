import 'package:flutter/foundation.dart';

import '../db/db_helper.dart';
import '../models/insumo.dart';

class InsumosProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  List<Insumo> insumos = [];
  bool cargando = false;

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    insumos = await _db.obtenerInsumos();
    cargando = false;
    notifyListeners();
  }

  Future<void> crear(Insumo i) async {
    await _db.crearInsumo(i);
    await cargar();
  }

  Future<void> actualizar(Insumo i) async {
    await _db.actualizarInsumo(i);
    await cargar();
  }

  Future<void> desactivar(int id) async {
    await _db.desactivarInsumo(id);
    await cargar();
  }
}