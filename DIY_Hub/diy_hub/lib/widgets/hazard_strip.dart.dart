// lib/widgets/hazard_strip.dart
// A band of diagonal yellow and black stripes (construction-tape look),
// used at the bottom of long screens and on the splash screen.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

class HazardStrip extends StatelessWidget {
  /// Height of the striped area (the ink borders are added on top and bottom).
  final double height;

  const HazardStrip({super.key, this.height = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border.symmetric(horizontal: AppTheme.border),
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ClipRect(
          child: CustomPaint(painter: _HazardPainter()),
        ),
      ),
    );
  }
}

class _HazardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Yellow base.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.actionYellow,
    );

    // Black slanted stripes.
    final stripe = Paint()..color = AppColors.ink;
    final h = size.height;
    final stripeWidth = h; // width of each black stripe
    final period = stripeWidth * 2; // black + yellow

    for (double x = -h; x < size.width + h; x += period) {
      final path = Path()
        ..moveTo(x, h)
        ..lineTo(x + h, 0)
        ..lineTo(x + h + stripeWidth, 0)
        ..lineTo(x + stripeWidth, h)
        ..close();
      canvas.drawPath(path, stripe);
    }
  }

  @override
  bool shouldRepaint(covariant _HazardPainter oldDelegate) => false;
}
