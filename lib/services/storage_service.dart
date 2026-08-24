import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Guardado local, 100% offline. No depende de internet en ningún momento.
/// Guarda todo el estado del juego como un único blob JSON bajo una clave.
class StorageService {
  static const _key = 'culinary_fusion_save_v1';

  Future<void> save(Map<String, dynamic> state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }

  Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      // Datos corruptos: nunca hacer que la app falle, simplemente
      // empezar una partida nueva en lugar de romper el arranque.
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
