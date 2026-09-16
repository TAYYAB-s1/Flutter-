// lib/widgets/power_meter_bar.dart
// Thick, comic-outlined progress bar labeled "Power Meter" — used on the
// "Continue Learning" banner to show how far along the active mission is.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PowerMeterBar extends StatelessWidget {
  final double percent; // 0.0 - 1.0
  final Color fillColor;
  final bool showLabel;

  const PowerMeterBar({
    super.key,
    required this.percent,
    this.fillColor = AppColors.comicBlue,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final track = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final clamped = percent.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'POWER METER',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                ),
                Text(
                  '${(clamped * 100).round()}% COMPLETED',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 14,
            decoration: BoxDecoration(
              color: track,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: outline, width: 2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped,
              child: Container(color: fillColor),
            ),
          ),
        ),
      ],
    );
  }
}