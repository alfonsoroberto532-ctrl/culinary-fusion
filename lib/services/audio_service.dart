import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Servicio de audio. Reproduce los efectos de sonido y la música de
/// fondo del juego, respetando los interruptores MÚSICA ON/OFF,
/// SONIDOS ON/OFF y VIBRACIÓN ON/OFF.
///
/// Todos los archivos se leen desde `assets/audio/` (declarados en
/// pubspec.yaml). Si un archivo todavía no existe, el reproductor
/// simplemente no suena — no rompe la app (ver catch silencioso en
/// [_playSfx] y [playBackgroundMusic]).
class AudioService {
  bool musicEnabled = true;
  bool sfxEnabled = true;
  bool vibrationEnabled = true;

  // Un reproductor dedicado para música (loop) y un pool pequeño para
  // efectos, así dos sonidos pueden superponerse sin cortarse entre sí.
  final AudioPlayer _musicPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
  final List<AudioPlayer> _sfxPool = List.generate(4, (_) => AudioPlayer());
  int _sfxCursor = 0;

  Future<void> _playSfx(String fileName) async {
    if (!sfxEnabled) return;
    try {
      final player = _sfxPool[_sfxCursor % _sfxPool.length];
      _sfxCursor++;
      await player.stop();
      await player.play(AssetSource('audio/$fileName'), volume: 0.9);
    } catch (_) {
      // El archivo aún no fue agregado a assets/audio/: no interrumpe el juego.
    }
  }

  void _vibrate() {
    if (!vibrationEnabled) return;
    HapticFeedback.lightImpact();
  }

  void playMerge() {
    _playSfx('merge.mp3');
    _vibrate();
  }

  void playDiscovery() {
    _playSfx('discovery.mp3');
    _vibrate();
  }

  void playCoins() {
    _playSfx('coins.mp3');
  }

  void playOrderDelivered() {
    _playSfx('order_delivered.mp3');
    _vibrate();
  }

  void playRestoration() {
    _playSfx('restoration.mp3');
  }

  Future<void> playBackgroundMusic() async {
    if (!musicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource('audio/music_loop.mp3'), volume: 0.4);
    } catch (_) {
      // El archivo de música aún no fue agregado.
    }
  }

  Future<void> stopBackgroundMusic() => _musicPlayer.stop();

  void toggleMusic(bool value) {
    musicEnabled = value;
    if (value) {
      playBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }
  }

  void toggleSfx(bool value) => sfxEnabled = value;
  void toggleVibration(bool value) => vibrationEnabled = value;

  void dispose() {
    _musicPlayer.dispose();
    for (final p in _sfxPool) {
      p.dispose();
    }
  }
}