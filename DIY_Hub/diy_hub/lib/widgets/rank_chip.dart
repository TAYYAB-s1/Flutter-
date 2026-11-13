// lib/widgets/rank_chip.dart
// The white chip in the app header: "CADET • 750 XP".

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../models/user_stats_model.dart';

class RankChip extends StatelessWidget {
  final String label;

  const RankChip({super.key, required this.label});

  /// Builds "CADET • 750 XP" from the saved user stats.
  factory RankChip.fromStats(UserStatsModel stats, {Key? key}) {
    return RankChip(
      key: key,
      label: '${stats.currentRank.label.toUpperCase()} • ${stats.totalXp} XP',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.fromBorderSide(AppTheme.tagBorder),
      ),
      child: Text(label.toUpperCase(), style: AppText.tag(size: 12)),
    );
  }
}
