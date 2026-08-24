/// Servicio de audio. En esta primera versión funcional deja los "hooks"
/// listos (música, fusión, descubrimiento, monedas, pedidos, restauración)
/// para conectar assets de sonido reales sin tocar el resto del código.
/// Respeta los interruptores MÚSICA ON/OFF, SONIDOS ON/OFF, VIBRACIÓN ON/OFF.
class AudioService {
  bool musicEnabled = true;
  bool sfxEnabled = true;
  bool vibrationEnabled = true;

  void playMerge() {
    if (!sfxEnabled) return;
    // TODO: reproducir sonido de fusión (assets/audio/merge.mp3)
  }

  void playDiscovery() {
    if (!sfxEnabled) return;
    // TODO: reproducir sonido de descubrimiento
  }

  void playCoins() {
    if (!sfxEnabled) return;
    // TODO: reproducir sonido de monedas
  }

  void playOrderDelivered() {
    if (!sfxEnabled) return;
    // TODO: reproducir sonido de pedido entregado
  }

  void playRestoration() {
    if (!sfxEnabled) return;
    // TODO: reproducir sonido de restauración
  }

  void toggleMusic(bool value) => musicEnabled = value;
  void toggleSfx(bool value) => sfxEnabled = value;
  void toggleVibration(bool value) => vibrationEnabled = value;
}
