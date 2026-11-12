// lib/widgets/rank_badge.dart
// White square tag with 1, 2 or 3 stars and the rank name
// (NOVICE / CADET / MASTER). This is the DIFFICULTY RANK, never the tier.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../models/skill_model.dart';

class RankBadge extends StatelessWidget {
  final DifficultyRank rank;
  final bool showLabel;

  const RankBadge({super.key, required this.rank, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.fromBorderSide(AppTheme.tagBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rank.starCount; i++)
            const Icon(Icons.star, size: 13, color: AppColors.ink),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(rank.label.toUpperCase(), style: AppText.tag()),
          ],
        ],
      ),
    );
  }
}
