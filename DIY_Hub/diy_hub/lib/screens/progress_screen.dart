// lib/screens/progress_screen.dart
// "Progress" tab — shows total XP, current rank with progress to the next
// rank, missions still in progress, and a trophy case of completed ones.
// Rendered as a tab body inside HomeScreen's shared Scaffold (no own AppBar).

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/skills_data.dart';
import '../models/progress_model.dart';
import '../models/skill_model.dart';
import '../models/user_stats_model.dart';
import '../services/progress_service.dart';
import '../widgets/power_meter_bar.dart';

class ProgressScreen extends StatefulWidget {
  final ValueChanged<SkillModel>? onOpenSkill;

  const ProgressScreen({super.key, this.onOpenSkill});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _progressService = ProgressService();
  UserStatsModel? _stats;
  Map<String, ProgressModel> _allProgress = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await _progressService.getUserStats();
    final progress = await _progressService.getAllProgress();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _allProgress = progress;
      _loading = false;
    });
  }

  Color _rankColor(DifficultyRank rank) {
    switch (rank) {
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
    if (_loading || _stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = _stats!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark ? AppColors.darkOutline : AppColors.lightOutline;

    final inProgress = <SkillModel>[];
    final completed = <SkillModel>[];
    for (final skill in SkillsData.all) {
      final progress = _allProgress[skill.id];
      if (progress == null || progress.completedLessonIds.isEmpty) continue;
      if (progress.isCompleted) {
        completed.add(skill);
      } else {
        inProgress.add(skill);
      }
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Rank / XP header card ────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _rankColor(stats.currentRank),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black87, width: 2.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'RANK: ${stats.currentRank.label.toUpperCase()}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '⚡ ${stats.totalXp} Total XP  •  ${stats.heroTier.title}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 14),
                if (stats.xpToNextRank != null) ...[
                  Text(
                    '${stats.xpToNextRank} XP TO NEXT RANK',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  PowerMeterBar(
                    percent: _rankProgressPercent(stats),
                    fillColor: Colors.white,
                    showLabel: false,
                  ),
                ] else
                  const Text(
                    '🏆 Maximum Rank Achieved!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── In Progress ──────────────────────────────────────────
          Text('IN PROGRESS', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (inProgress.isEmpty)
            _EmptyRow(text: 'No missions in progress. Start one from the Categories tab!')
          else
            ...inProgress.map((skill) {
              final progress = _allProgress[skill.id]!;
              final percent = progress.progressPercent(skill.lessons.length);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => widget.onOpenSkill?.call(skill),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: outline, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(skill.icon, color: skill.accentColor, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(skill.title, style: Theme.of(context).textTheme.titleMedium),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        PowerMeterBar(
                          percent: percent,
                          fillColor: skill.accentColor,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

          const SizedBox(height: 24),

          // ── Trophy Case ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TROPHY CASE', style: Theme.of(context).textTheme.titleLarge),
              Text('${completed.length} earned', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          if (completed.isEmpty)
            _EmptyRow(text: 'Complete your first mission to earn a trophy!')
          else
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: completed.map((skill) {
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => widget.onOpenSkill?.call(skill),
                  child: Container(
                    decoration: BoxDecoration(
                      color: skill.accentColor.withOpacity(isDark ? 0.3 : 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: outline, width: 2),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(skill.icon, size: 32, color: skill.accentColor),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                                child: const Icon(Icons.check, size: 10, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          skill.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Progress toward the next rank threshold, as a 0..1 fraction for the bar.
  double _rankProgressPercent(UserStatsModel stats) {
    final int lowerBound;
    final int upperBound;
    switch (stats.currentRank) {
      case DifficultyRank.novice:
        lowerBound = 0;
        upperBound = UserStatsModel.cadetThreshold;
        break;
      case DifficultyRank.cadet:
        lowerBound = UserStatsModel.cadetThreshold;
        upperBound = UserStatsModel.masterThreshold;
        break;
      case DifficultyRank.master:
        return 1.0;
    }
    final span = upperBound - lowerBound;
    if (span <= 0) return 1.0;
    return ((stats.totalXp - lowerBound) / span).clamp(0, 1).toDouble();
  }
}

class _EmptyRow extends StatelessWidget {
  final String text;
  const _EmptyRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}