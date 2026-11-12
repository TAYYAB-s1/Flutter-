// lib/widgets/block_progress_bar.dart
// Chunky segmented progress bar (replaces the old comic "power meter").
// percent is 0..1. A little progress always shows at least one block.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

class BlockProgressBar extends StatelessWidget {
  final double percent;
  final int blocks;
  final Color fillColor;
  final double height;

  const BlockProgressBar({
    super.key,
    required this.percent,
    this.blocks = 10,
    this.fillColor = AppColors.actionYellow,
    this.height = 18,
  });

  @override
  Widget build(BuildContext context) {
    var filled = 0;
    if (percent > 0) {
      filled = (percent * blocks).round();
      if (filled < 1) filled = 1;
      if (filled > blocks) filled = blocks;
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.fromBorderSide(AppTheme.tagBorder),
      ),
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < blocks; i++)
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i == blocks - 1 ? 0 : 3),
                  color: i < filled ? fillColor : AppColors.lightDivider,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
