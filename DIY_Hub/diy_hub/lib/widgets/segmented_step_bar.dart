// lib/widgets/segmented_step_bar.dart
// Blocky step indicator for the Mission Player: one block per step in the
// current episode. Done = green, current = [currentColor], upcoming = empty.
// [current] is 1-based (Step 2 of 3 => total: 3, current: 2).

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SegmentedStepBar extends StatelessWidget {
  final int total;
  final int current;
  final Color currentColor;
  final Color doneColor;

  /// True on the black Player stage (white outlines); false on cream pages.
  final bool onDark;

  const SegmentedStepBar({
    super.key,
    required this.total,
    required this.current,
    this.currentColor = AppColors.inProgress,
    this.doneColor = AppColors.success,
    this.onDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final outline = onDark ? AppColors.white : AppColors.ink;

    return SizedBox(
      height: 14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < total; i++)
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                decoration: BoxDecoration(
                  color: (i + 1) < current
                      ? doneColor
                      : ((i + 1) == current
                          ? currentColor
                          : Colors.transparent),
                  border: Border.all(color: outline, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
