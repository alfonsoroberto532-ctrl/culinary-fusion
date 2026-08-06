import 'package:flutter/foundation.dart';

import '../services/license_service.dart';

class LicenseProvider extends ChangeNotifier {
  bool verificando = true;
  bool activa = false;
  String codigoDispositivo = '';

  Future<void> verificar() async {
    verificando = true;
    notifyListeners();
    codigoDispositivo = await LicenseService.generarCodigoDispositivo();
    final nivel = await LicenseService.obtenerNivelActual();
    activa = nivel == NivelApp.basico;
    verificando = false;
    notifyListeners();
  }

  Future<bool> activar(String licencia) async {
    final ok = await LicenseService.validarYActivar(licencia);
    if (ok) {
      activa = true;
      notifyListeners();
    }
    return ok;
  }
}