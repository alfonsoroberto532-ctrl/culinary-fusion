import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Dibuja el destello de fusión: un anillo que se expande y se desvanece,
/// más un puñado de partículas que salen disparadas desde el centro.
/// [progress] va de 0.0 (justo al fusionar) a 1.0 (animación terminada).
class FusionBurstPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  static const int particleCount = 10;

  FusionBurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.8;

    // Anillo expansivo que se desvanece.
    final ringProgress = Curves.easeOut.transform(progress);
    final ringOpacity = (1 - progress).clamp(0.0, 1.0);
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.55 * ringOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, maxRadius * 0.25 * ringProgress + 2, ringPaint);

    // Destello central breve (más intenso al inicio).
    final flashOpacity = (1 - progress * 2).clamp(0.0, 1.0);
    if (flashOpacity > 0) {
      final flashPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.7 * flashOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, maxRadius * 0.22, flashPaint);
    }

    // Partículas radiales.
    final particleProgress = Curves.easeOut.transform(progress);
    final particleOpacity = (1 - progress).clamp(0.0, 1.0);
    for (var i = 0; i < particleCount; i++) {
      final angle = (2 * math.pi / particleCount) * i + (progress * 0.6);
      final distance = maxRadius * particleProgress;
      final dx = center.dx + math.cos(angle) * distance;
      final dy = center.dy + math.sin(angle) * distance;
      final particleSize = 3.2 * (1 - progress) + 0.6;
      final paint = Paint()..color = color.withValues(alpha: particleOpacity);
      canvas.drawCircle(Offset(dx, dy), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FusionBurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
