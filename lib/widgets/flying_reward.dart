import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Dispara una animación de monedas volando desde [startGlobalPosition]
/// hasta la posición actual del widget marcado con [hudCoinKey] (el chip
/// de monedas del HUD, ver [GameHud.coinsKey]). Se inserta como
/// [OverlayEntry] temporal: no vive en el árbol de widgets normal, así
/// que funciona sin importar qué overlay/pantalla esté abierta encima.
void flyCoinsToHud(
  BuildContext context, {
  required Offset startGlobalPosition,
  required GlobalKey hudCoinKey,
  int coinCount = 6,
  VoidCallback? onLanded,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _FlyingCoinsLayer(
      start: startGlobalPosition,
      hudCoinKey: hudCoinKey,
      coinCount: coinCount,
      onComplete: () {
        entry.remove();
        onLanded?.call();
      },
    ),
  );
  overlay.insert(entry);
}

/// Punto sobre una curva de Bézier cuadrática (P0 → control → P2). Da un
/// arco natural en vez de una línea recta entre origen y destino.
Offset _quadBezier(Offset p0, Offset p1, Offset p2, double t) {
  final oneMinusT = 1 - t;
  final x = oneMinusT * oneMinusT * p0.dx + 2 * oneMinusT * t * p1.dx + t * t * p2.dx;
  final y = oneMinusT * oneMinusT * p0.dy + 2 * oneMinusT * t * p1.dy + t * t * p2.dy;
  return Offset(x, y);
}

class _FlyingCoinsLayer extends StatefulWidget {
  final Offset start;
  final GlobalKey hudCoinKey;
  final int coinCount;
  final VoidCallback onComplete;

  const _FlyingCoinsLayer({
    required this.start,
    required this.hudCoinKey,
    required this.coinCount,
    required this.onComplete,
  });

  @override
  State<_FlyingCoinsLayer> createState() => _FlyingCoinsLayerState();
}

class _FlyingCoinsLayerState extends State<_FlyingCoinsLayer> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  Offset? _end;

  static const _flightDuration = Duration(milliseconds: 620);
  static const _stagger = Duration(milliseconds: 55);

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.coinCount, (i) {
      final controller = AnimationController(vsync: this, duration: _flightDuration);
      Future.delayed(_stagger * i, () {
        if (mounted) controller.forward();
      });
      return controller;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveTarget());

    final totalTime = _flightDuration + (_stagger * widget.coinCount);
    Future.delayed(totalTime, () {
      if (mounted) widget.onComplete();
    });
  }

  void _resolveTarget() {
    final box = widget.hudCoinKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final pos = box.localToGlobal(box.size.center(Offset.zero));
    if (mounted) setState(() => _end = pos);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si el HUD todavía no resolvió su posición (primer frame), las
    // monedas esperan quietas en el origen en vez de volar a (0,0).
    final end = _end ?? widget.start;

    return IgnorePointer(
      child: Stack(
        children: List.generate(widget.coinCount, (i) {
          final rand = math.Random(i * 17 + 3);
          final controlPoint = Offset(
            (widget.start.dx + end.dx) / 2 + (rand.nextDouble() - 0.5) * 90,
            math.min(widget.start.dy, end.dy) - 70 - rand.nextDouble() * 50,
          );
          return AnimatedBuilder(
            animation: _controllers[i],
            builder: (context, _) {
              final t = Curves.easeInCubic.transform(_controllers[i].value);
              final pos = _quadBezier(widget.start, controlPoint, end, t);
              final v = _controllers[i].value;
              final opacity = v > 0.82 ? (1 - (v - 0.82) / 0.18).clamp(0.0, 1.0) : 1.0;
              final scale = 1.0 - (v * 0.35);
              return Positioned(
                left: pos.dx - 9,
                top: pos.dy - 9,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(scale: scale, child: const _CoinDot()),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _CoinDot extends StatelessWidget {
  const _CoinDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [Color(0xFFFFE082), AppColors.goldDark]),
        boxShadow: [BoxShadow(color: Color(0x552E1F0A), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: const Icon(Icons.savings_rounded, size: 11, color: Colors.white),
    );
  }
}
