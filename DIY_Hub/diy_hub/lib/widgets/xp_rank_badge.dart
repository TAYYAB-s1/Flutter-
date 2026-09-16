// lib/widgets/xp_rank_badge.dart
// Compact pill showing the user's current XP total, e.g. "⚡ 14".
// Used in the shared AppBar across Home/Categories/Progress/Favorites.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class XpRankBadge extends StatelessWidget {
  final int xp;

  const XpRankBadge({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 16, color: AppColors.comicYellow),
          const SizedBox(width: 4),
          Text(
            '$xp',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}