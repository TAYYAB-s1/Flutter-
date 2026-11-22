// lib/widgets/mission_grid.dart
// Responsive 2-column (3 on wide screens) grid of MissionCards. It uses a
// Wrap with computed widths instead of a fixed aspect ratio, so cards can be
// any height and never overflow. Used by Home search, Category Detail and
// Favorites.

import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/progress_model.dart';
import '../models/skill_model.dart';
import 'mission_card.dart';

class MissionGrid extends StatelessWidget {
  final List<SkillModel> skills;
  final Map<String, ProgressModel> progress;
  final ValueChanged<SkillModel> onOpen;
  final ValueChanged<SkillModel> onToggleFavorite;

  const MissionGrid({
    super.key,
    required this.skills,
    required this.progress,
    required this.onOpen,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        final columns = constraints.maxWidth >= 640 ? 3 : 2;
        // Leave room on the right for the hard shadow of the last column.
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1) - AppTheme.shadowOffset) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final skill in skills)
              SizedBox(
                width: cardWidth,
                child: MissionCard(
                  skill: skill,
                  isFavorite: progress[skill.id]?.isFavorite ?? false,
                  progressPercent:
                      progress[skill.id]?.progressPercent(skill.lessons.length) ?? 0,
                  completed: progress[skill.id]?.isCompleted ?? false,
                  onFavoriteToggle: () => onToggleFavorite(skill),
                  onTap: () => onOpen(skill),
                ),
              ),
          ],
        );
      },
    );
  }
}
