
// lib/widgets/comic_burst_badge.dart
// A jagged starburst shape with short bold text inside, used for
// "POW!", "NEW!", "HOT!", "ZAP!" style accent labels across the app.

import 'dart:math' as math;
import 'package:flutter/material.dart';

class ComicBurstBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final double size;
  final double rotationDegrees;

  const ComicBurstBadge({
    super.key,
    required this.text,
    this.color = const Color(0xFFE53935),
    this.textColor = Colors.white,
    this.size = 56,
    this.rotationDegrees = -8,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationDegrees * math.pi / 180,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _BurstPainter(color: color),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.19,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final Color color;
  static const int _points = 10;

  _BurstPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.68;

    final path = Path();
    for (int i = 0; i < _points * 2; i++) {
      final isOuter = i.isEven;
      final radius = isOuter ? outerRadius : innerRadius;
      final angle = (i * math.pi) / _points;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    final fillPaint = Paint()..color = color;
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) => oldDelegate.color != color;
}