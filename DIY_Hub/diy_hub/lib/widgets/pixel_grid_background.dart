// lib/widgets/pixel_grid_background.dart
// Faint square grid drawn behind a child. Used on the black "stage" panel
// of Mission Detail and on the full-screen Mission Player.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PixelGridBackground extends StatelessWidget {
  final Widget child;
  final double spacing;

  const PixelGridBackground(
      {super.key, required this.child, this.spacing = 16});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _GridPainter(spacing: spacing)),
        ),
        child,
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final double spacing;

  const _GridPainter({required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.stageGrid
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.spacing != spacing;
}
