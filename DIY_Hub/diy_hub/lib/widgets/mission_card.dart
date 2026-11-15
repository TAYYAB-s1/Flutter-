// lib/widgets/mission_card.dart
// The mission card used everywhere a mission (Skill) is listed. White card
// with a thick border and hard shadow:
//   cover (rank badge top-left, XP tag top-right, bookmark bottom-right)
//   title, "Robotics • 4 Episodes", optional progress bar,
//   time tag + tier tag + yellow play button.
//
// The card adapts to narrow widths (2-column grids on small phones) by
// showing only the stars on the rank badge.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../constants/category_style.dart';
import '../models/skill_model.dart';
import 'block_progress_bar.dart';
import 'brutal_card.dart';
import 'mission_cover.dart';
import 'rank_badge.dart';
import 'tech_tag.dart';
import 'xp_tag.dart';

class MissionCard extends StatelessWidget {
  final SkillModel skill;
  final VoidCallback onTap;
  final bool isFavorite;

  /// Shows the bookmark button on the cover when provided.
  final VoidCallback? onFavoriteToggle;

  /// 0..1. Shows a progress bar when greater than 0 and not completed.
  final double progressPercent;

  /// Shows a green check on the cover.
  final bool completed;

  const MissionCard({
    super.key,
    required this.skill,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.progressPercent = 0,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    final inProgress = progressPercent > 0 && !completed;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 200;

        return BrutalCard(
          onTap: onTap,
          clipBehavior: Clip.hardEdge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MissionCover(
                skill: skill,
                aspectRatio: 1.7,
                iconBoxSize: compact ? 48 : 56,
                topLeft:
                    RankBadge(rank: skill.difficultyRank, showLabel: !compact),
                topRight: XpTag(xp: skill.xpReward),
                bottomLeft: completed ? const _DoneSticker() : null,
                bottomRight: onFavoriteToggle == null
                    ? null
                    : _BookmarkButton(
                        isFavorite: isFavorite, onTap: onFavoriteToggle!),
              ),
              Container(height: AppTheme.borderWidth, color: AppColors.ink),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.title.toUpperCase(),
                      style: AppText.display(
                          size: compact ? 14 : 16, height: 1.15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${CategoryStyle.shortLabel(skill.category)} • ${skill.lessons.length} Episodes',
                      style: AppText.caption(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (inProgress) ...[
                      const SizedBox(height: 10),
                      BlockProgressBar(
                        percent: progressPercent,
                        blocks: 8,
                        height: 10,
                        fillColor: skill.accentColor,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TechTag.time(skill.estimatedMinutes),
                        TechTag.tier(skill.minHeroTier),
                        const _PlayButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Yellow square play button (decorative: the whole card is tappable).
class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.actionYellow,
        border: Border.fromBorderSide(AppTheme.tagBorder),
      ),
      child: const Icon(Icons.play_arrow, size: 22, color: AppColors.ink),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _BookmarkButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isFavorite ? 'Remove from saved' : 'Save mission',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isFavorite ? AppColors.actionYellow : AppColors.white,
            border: Border.fromBorderSide(AppTheme.tagBorder),
          ),
          child: Icon(
            isFavorite ? Icons.bookmark : Icons.bookmark_border,
            size: 20,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _DoneSticker extends StatelessWidget {
  const _DoneSticker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.success,
        border: Border.fromBorderSide(AppTheme.tagBorder),
      ),
      child: const Icon(Icons.check, size: 18, color: AppColors.ink),
    );
  }
}
