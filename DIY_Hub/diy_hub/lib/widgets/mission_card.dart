// lib/widgets/mission_card.dart
// The core comic-panel card used everywhere a mission (Skill) is listed:
// Home's Trending Quests, the Category screen list, Favorites, etc.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/skill_model.dart';
import 'comic_burst_badge.dart';
import 'halftone_background.dart';

class MissionCard extends StatelessWidget {
  final SkillModel skill;
  final VoidCallback onTap;
  final String? burstLabel;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const MissionCard({
    super.key,
    required this.skill,
    required this.onTap,
    this.burstLabel,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  Color _rankColor() {
    switch (skill.difficultyRank) {
      case DifficultyRank.novice:
        return AppColors.rankNovice;
      case DifficultyRank.cadet:
        return AppColors.rankCadet;
      case DifficultyRank.master:
        return AppColors.rankMaster;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark ? AppColors.darkOutline : AppColors.lightOutline;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Illustration header area ──────────────────────────
            SizedBox(
              height: 130,
              width: double.infinity,
              child: HalftoneBackground(
                dotColor: Colors.black.withOpacity(0.08),
                child: Container(
                  color: skill.accentColor.withOpacity(0.35),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(skill.icon, size: 56, color: outline),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _RankPill(rank: skill.difficultyRank, color: _rankColor()),
                      ),
                      if (burstLabel != null)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: ComicBurstBadge(text: burstLabel!, size: 48),
                        ),
                      if (onFavoriteToggle != null)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: _FavoriteButton(
                            isFavorite: isFavorite,
                            onTap: onFavoriteToggle!,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Text content ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skill.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                      const SizedBox(width: 4),
                      Text(
                        '${skill.estimatedMinutes} mins • ${skill.stepCount} steps',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt, size: 16, color: AppColors.comicYellow),
                          const SizedBox(width: 2),
                          Text('+${skill.xpReward} XP', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: skill.accentColor,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        onPressed: onTap,
                        child: const Text('START CRAFT →', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankPill extends StatelessWidget {
  final DifficultyRank rank;
  final Color color;

  const _RankPill({required this.rank, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Text(
        '${'★' * rank.starCount} ${rank.label.toUpperCase()}',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Icon(
          isFavorite ? Icons.bookmark : Icons.bookmark_border,
          size: 16,
          color: Colors.black,
        ),
      ),
    );
  }
}