import 'package:flutter/foundation.dart';

import '../db/db_helper.dart';
import '../models/configuracion.dart';

class ConfiguracionProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  Configuracion configuracion = Configuracion.porDefecto();
  bool cargando = false;

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    configuracion = await _db.obtenerConfiguracion();
    cargando = false;
    notifyListeners();
  }

  Future<void> guardar(Configuracion nueva) async {
    await _db.guardarConfiguracion(nueva);
    configuracion = nueva;
    notifyListeners();
  }
}