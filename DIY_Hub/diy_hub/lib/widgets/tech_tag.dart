// lib/widgets/tech_tag.dart
// Small square monospace tag: "35 MIN", "MAKER", "4 EPISODES".
// Optional colored square bullet (used for the Tier tag) or leading icon.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../models/skill_model.dart';

/// Short tier names used on cards. Never confuse these with ranks.
String tierShortLabel(HeroTier tier) {
  switch (tier) {
    case HeroTier.kids:
      return 'Rookie';
    case HeroTier.teens:
      return 'Maker';
    case HeroTier.adult:
      return 'Artisan';
  }
}

Color tierColor(HeroTier tier) {
  switch (tier) {
    case HeroTier.kids:
      return AppColors.tierKids;
    case HeroTier.teens:
      return AppColors.tierTeens;
    case HeroTier.adult:
      return AppColors.tierAdult;
  }
}

class TechTag extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? bulletColor;
  final Color background;
  final Color textColor;

  const TechTag({
    super.key,
    required this.label,
    this.icon,
    this.bulletColor,
    this.background = AppColors.white,
    this.textColor = AppColors.ink,
  });

  /// "35 MIN" with a clock icon.
  factory TechTag.time(int minutes, {Key? key}) {
    return TechTag(key: key, label: '$minutes min', icon: Icons.schedule);
  }

  /// "MAKER" with a tier-colored bullet.
  factory TechTag.tier(HeroTier tier, {Key? key}) {
    return TechTag(
        key: key, label: tierShortLabel(tier), bulletColor: tierColor(tier));
  }

  /// "4 EPISODES".
  factory TechTag.episodes(int count, {Key? key}) {
    return TechTag(
        key: key, label: '$count episodes', icon: Icons.layers_outlined);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        border: Border.fromBorderSide(AppTheme.tagBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (bulletColor != null) ...[
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: bulletColor,
                border: Border.all(color: AppColors.ink, width: 1.5),
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label.toUpperCase(),
              style: AppText.tag(color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
