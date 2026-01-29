import 'dart:math';
import 'package:flutter/material.dart';

class RadialVisualizer extends CustomPainter {
  final double inhale;
  final double hold;
  final double exhale;
  final double holdEmpty;

  RadialVisualizer({
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.holdEmpty,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final total = inhale + hold + exhale + holdEmpty;
    
    if (total == 0) return;

    double startAngle = -pi / 2;

    void drawSegment(double value, Color color, bool isTrans) {
      if (value <= 0) return;
      final sweepAngle = (value / total) * 2 * pi;
      final paint = Paint()
        ..color = isTrans ? color.withOpacity(0.1) : color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;

      if (!isTrans) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 3);
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    drawSegment(inhale, Colors.cyanAccent, false);
    drawSegment(hold, Colors.greenAccent, false);
    drawSegment(exhale, Colors.orangeAccent, false);
    drawSegment(holdEmpty, Colors.deepPurpleAccent, false);
  }

  @override
  bool shouldRepaint(covariant RadialVisualizer oldDelegate) {
    return oldDelegate.inhale != inhale ||
           oldDelegate.hold != hold ||
           oldDelegate.exhale != exhale ||
           oldDelegate.holdEmpty != holdEmpty;
  }
}
