import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Nivel de activación ──────────────────────────────────────────────────────
enum NivelApp { basico, bloqueado }

class LicenseService {
  // ── SharedPreferences keys ─────────────────────────────────────────────────
  static const String _keyActivado = 'app_activada';
  static const String _keyLicencia = 'app_licencia';

  // ── Constantes de firma ────────────────────────────────────────────────────
  // Misma clave que VaraNova/GestorV, para mantener el mismo patrón en la suite.
  // Si prefieres aislar esta app, cambia esta clave por una distinta.
  static const String _claveSecreta = 'MITHRA22';
  static const String _prefijo = 'BH'; // Business Hostal — único prefijo, sin roles.

  // ─── ID de dispositivo ────────────────────────────────────────────────────
  static Future<String> obtenerIdDispositivo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      final serial = info.serialNumber;
      if (serial.isNotEmpty && serial != 'unknown') return serial;
      return '${info.brand}-${info.model}-${info.hardware}';
    }

    if (Platform.isWindows) {
      final info = await deviceInfo.windowsInfo;
      if (info.deviceId.isNotEmpty) return info.deviceId;
      return '${info.computerName}-${info.productId}';
    }

    if (Platform.isLinux) {
      final info = await deviceInfo.linuxInfo;
      if (info.machineId != null && info.machineId!.isNotEmpty) {
        return info.machineId!;
      }
      return '${info.name}-${info.id}';
    }

    if (Platform.isMacOS) {
      final info = await deviceInfo.macOsInfo;
      if (info.systemGUID != null && info.systemGUID!.isNotEmpty) {
        return info.systemGUID!;
      }
      return '${info.model}-${info.computerName}';
    }

    return 'unknown-device';
  }

  // ─── Código visible para el cliente (XXXX-XXXX-XXXX) ─────────────────────
  static Future<String> generarCodigoDispositivo() async {
    final id = await obtenerIdDispositivo();
    final hash = sha256.convert(utf8.encode(id)).toString().toUpperCase();
    return '${hash.substring(0, 4)}-'
        '${hash.substring(4, 8)}-'
        '${hash.substring(8, 12)}';
  }

  // ─── Token de fecha → DateTime ────────────────────────────────────────────
  static DateTime _tokenAFecha(String token) {
    final n = int.parse(token, radix: 36);
    final d = n % 100;
    final m = (n ~/ 100) % 100;
    final y = n ~/ 10000;
    return DateTime(y, m, d);
  }

  // ─── Reconstruye la licencia esperada ─────────────────────────────────────
  static String _crearLicencia(String codigoDispositivo, String tokFecha) {
    final input =
        _prefijo +
        codigoDispositivo.replaceAll('-', '') +
        tokFecha +
        _claveSecreta;
    final hash = sha256.convert(utf8.encode(input)).toString().toUpperCase();
    return '$_prefijo-$tokFecha-${hash.substring(0, 10)}';
  }

  // ─── Valida y activa ────────────────────────────────────────────────────────
  /// Devuelve true si la licencia es válida y se activó correctamente.
  static Future<bool> validarYActivar(String licenciaIngresada) async {
    try {
      final entrada = licenciaIngresada.trim().toUpperCase();
      final partes = entrada.split('-');
      if (partes.length != 3) return false;

      final prefijo = partes[0];
      final tokFecha = partes[1];

      if (prefijo != _prefijo) return false;

      // Verificar fecha de expiración
      final expiracion = _tokenAFecha(tokFecha);
      if (DateTime.now().isAfter(expiracion)) return false;

      // Verificar firma contra el dispositivo actual
      final codigoDisp = await generarCodigoDispositivo();
      final licenciaEsperada = _crearLicencia(codigoDisp, tokFecha);

      if (entrada == licenciaEsperada.toUpperCase()) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyActivado, true);
        await prefs.setString(_keyLicencia, entrada);
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  // ─── Nivel actual (re-valida fecha en cada arranque) ─────────────────────
  static Future<NivelApp> obtenerNivelActual() async {
    final prefs = await SharedPreferences.getInstance();
    final activado = prefs.getBool(_keyActivado) ?? false;
    if (!activado) return NivelApp.bloqueado;

    final lic = prefs.getString(_keyLicencia) ?? '';
    final partes = lic.split('-');
    if (partes.length != 3) return NivelApp.bloqueado;

    try {
      final expiracion = _tokenAFecha(partes[1]);
      if (DateTime.now().isAfter(expiracion)) {
        await desactivar();
        return NivelApp.bloqueado;
      }
    } catch (_) {
      return NivelApp.bloqueado;
    }

    return NivelApp.basico;
  }

  // ─── Desactivar ───────────────────────────────────────────────────────────
  static Future<void> desactivar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActivado);
    await prefs.remove(_keyLicencia);
  }
}
