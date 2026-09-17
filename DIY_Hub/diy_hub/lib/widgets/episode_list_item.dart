// lib/widgets/episode_list_item.dart
// A single numbered row in the "Mission Episodes" list on Skill Detail.
// Visually reflects whether an episode is completed, the current
// objective, or still locked behind earlier episodes.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum EpisodeState { completed, current, upcoming, locked }

class EpisodeListItem extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final EpisodeState state;
  final Color accentColor;
  final VoidCallback? onTap;

  const EpisodeListItem({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.state,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final isLocked = state == EpisodeState.locked;
    final isCurrent = state == EpisodeState.current;
    final isCompleted = state == EpisodeState.completed;

    return Opacity(
      opacity: isLocked ? 0.55 : 1.0,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrent ? accentColor : outline,
              width: isCurrent ? 3 : 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepBadge(
                number: number,
                isCompleted: isCompleted,
                isLocked: isLocked,
                accentColor: accentColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCurrent)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.comicRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'CURRENT OBJECTIVE',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.comicRed,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isLocked)
                const Icon(Icons.lock, size: 20, color: AppColors.locked)
              else if (isCurrent)
                Icon(Icons.play_circle_fill, size: 26, color: accentColor)
              else if (!isCompleted)
                Icon(Icons.chevron_right, size: 22, color: outline.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final int number;
  final bool isCompleted;
  final bool isLocked;
  final Color accentColor;

  const _StepBadge({
    required this.number,
    required this.isCompleted,
    required this.isLocked,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isCompleted ? AppColors.success : (isLocked ? AppColors.locked : accentColor);

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black87, width: 1.5),
      ),
      child: isCompleted
          ? const Icon(Icons.check, size: 18, color: Colors.white)
          : Text(
              '$number',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
            ),
    );
  }
}