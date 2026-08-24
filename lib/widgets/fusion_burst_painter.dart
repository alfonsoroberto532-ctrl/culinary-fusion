import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Dibuja el destello de fusión: doble anillo expansivo, un flash central
/// dorado + del color de rareza, y partículas disparadas desde el centro
/// con tamaños variados (mezcla de "chispas" grandes y polvo fino) para
/// un efecto más vistoso que un burst plano de un solo color.
/// [progress] va de 0.0 (justo al fusionar) a 1.0 (animación terminada).
class FusionBurstPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  static const int particleCount = 18;

  FusionBurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.85;

    // Anillo exterior (del color de rareza) + anillo interior dorado,
    // desfasados en el tiempo para dar sensación de "onda doble".
    final ringOpacity = (1 - progress).clamp(0.0, 1.0);
    final outerRingProgress = Curves.easeOut.transform(progress);
    canvas.drawCircle(
      center,
      maxRadius * 0.30 * outerRingProgress + 2,
      Paint()
        ..color = color.withValues(alpha: 0.55 * ringOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    final innerRingProgress = Curves.easeOut.transform((progress - 0.12).clamp(0.0, 1.0));
    canvas.drawCircle(
      center,
      maxRadius * 0.22 * innerRingProgress + 2,
      Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.5 * ringOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Destello central breve (más intenso al inicio, mezcla blanco+dorado).
    final flashOpacity = (1 - progress * 2).clamp(0.0, 1.0);
    if (flashOpacity > 0) {
      canvas.drawCircle(
        center,
        maxRadius * 0.24,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.75 * flashOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );
      canvas.drawCircle(
        center,
        maxRadius * 0.34,
        Paint()
          ..color = const Color(0xFFFFD54F).withValues(alpha: 0.35 * flashOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }

    // Partículas radiales: alternan color de rareza y dorado, con
    // tamaños variados para que no se vea un anillo uniforme.
    final particleProgress = Curves.easeOut.transform(progress);
    final particleOpacity = (1 - progress).clamp(0.0, 1.0);
    for (var i = 0; i < particleCount; i++) {
      final angle = (2 * math.pi / particleCount) * i + (progress * 0.6);
      final isSpark = i.isEven;
      final distance = maxRadius * particleProgress * (isSpark ? 1.0 : 0.72);
      final dx = center.dx + math.cos(angle) * distance;
      final dy = center.dy + math.sin(angle) * distance;
      final particleSize = (isSpark ? 3.6 : 2.0) * (1 - progress) + 0.5;
      final particleColor = isSpark ? color : const Color(0xFFFFD54F);
      canvas.drawCircle(
        Offset(dx, dy),
        particleSize,
        Paint()..color = particleColor.withValues(alpha: particleOpacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FusionBurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}