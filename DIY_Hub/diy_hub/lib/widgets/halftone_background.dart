// lib/widgets/halftone_background.dart
// Renders a faint grid of dots behind its child, giving surfaces the
// classic comic-book / newsprint halftone texture. Used behind hero
// banners, category tiles, and section headers.

import 'package:flutter/material.dart';

class HalftoneBackground extends StatelessWidget {
  final Widget child;
  final Color dotColor;
  final double dotSpacing;
  final double dotRadius;
  final BorderRadius? borderRadius;

  const HalftoneBackground({
    super.key,
    required this.child,
    required this.dotColor,
    this.dotSpacing = 14,
    this.dotRadius = 1.6,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _HalftonePainter(
              dotColor: dotColor,
              spacing: dotSpacing,
              radius: dotRadius,
            ),
          ),
        ),
        child,
      ],
    );

    if (borderRadius == null) return content;
    return ClipRRect(borderRadius: borderRadius!, child: content);
  }
}

class _HalftonePainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double radius;

  _HalftonePainter({required this.dotColor, required this.spacing, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    for (double y = 0; y < size.height; y += spacing) {
      // Offset every other row for a classic staggered halftone look.
      final rowOffset = ((y ~/ spacing) % 2 == 0) ? 0.0 : spacing / 2;
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        canvas.drawCircle(Offset(x + rowOffset, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HalftonePainter oldDelegate) {
    return oldDelegate.dotColor != dotColor ||
        oldDelegate.spacing != spacing ||
        oldDelegate.radius != radius;
  }
}