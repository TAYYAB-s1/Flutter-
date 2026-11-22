// lib/widgets/stage_grid.dart
// The black "stage" backdrop with a faint pixel grid, used by the Mission
// Detail stage panel and the Mission Player. Black here is a fixed design
// accent (not a dark theme).

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StageGrid extends StatelessWidget {
  final Widget child;
  final Color background;
  final double spacing;

  const StageGrid({
    super.key,
    required this.child,
    this.background = AppColors.ink,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: CustomPaint(
        painter: _GridPainter(spacing),
        child: child,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double spacing;

  const _GridPainter(this.spacing);

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
  bool shouldRepaint(covariant _GridPainter oldDelegate) => oldDelegate.spacing != spacing;
}
