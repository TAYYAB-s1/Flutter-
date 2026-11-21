// lib/screens/progress_screen.dart
// The STATS tab: your rank card (XP and progress to the next rank), the
// missions you have started, and a trophy case of finished missions.
// Rendered as a tab body inside HomeScreen's shared Scaffold.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../constants/category_style.dart';
import '../constants/skills_data.dart';
import '../models/progress_model.dart';
import '../models/skill_model.dart';
import '../models/user_stats_model.dart';
import '../services/progress_service.dart';
import '../widgets/block_progress_bar.dart';
import '../widgets/brutal_button.dart';
import '../widgets/brutal_card.dart';
import '../widgets/halftone_background.dart';
import '../widgets/hazard_strip.dart';
import '../widgets/mission_cover.dart';
import '../widgets/sticker_label.dart';
import '../widgets/xp_tag.dart';

class ProgressScreen extends StatefulWidget {
  /// Opens a mission. Awaited, so this tab can refresh when you come back.
  final Future<void> Function(SkillModel)? onOpenSkill;

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

  Future<void> _open(SkillModel skill) async {
    final open = widget.onOpenSkill;
    if (open == null) return;
    await open(skill);
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    if (_loading || stats == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.ink));
    }

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
      color: AppColors.ink,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          Text('PROGRESS', style: AppText.display(size: 30)),
          const SizedBox(height: 8),
          Text(
            'LEVEL UP BY FINISHING MISSIONS',
            style: AppText.tag(size: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          _RankCard(stats: stats),
          const SizedBox(height: 28),
          _SectionHeader(
              label: 'In progress', trailing: '${inProgress.length} ACTIVE'),
          const SizedBox(height: 14),
          if (inProgress.isEmpty)
            const _EmptyNote(
                text:
                    'Nothing in progress yet. Pick a lab and start a mission!')
          else
            for (final skill in inProgress)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _InProgressRow(
                  skill: skill,
                  progress: _allProgress[skill.id]!,
                  onOpen: () => _open(skill),
                ),
              ),
          const SizedBox(height: 12),
          _SectionHeader(
              label: 'Trophy case', trailing: '${completed.length} EARNED'),
          const SizedBox(height: 14),
          if (completed.isEmpty)
            const _EmptyNote(
                text: 'Finish a mission to earn your first trophy.')
          else
            _TrophyGrid(skills: completed, onOpen: _open),
          const SizedBox(height: 28),
          const HazardStrip(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final String trailing;

  const _SectionHeader({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StickerLabel(text: label),
        const Spacer(),
        Text(trailing, style: AppText.tag(size: 12, color: AppColors.muted)),
      ],
    );
  }
}

/// Small card used when a list is empty.
class _EmptyNote extends StatelessWidget {
  final String text;

  const _EmptyNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      padding: const EdgeInsets.all(16),
      child: Text(text, style: AppText.bodyMuted()),
    );
  }
}

/// Big colored rank card: rank, total XP and progress toward the next rank.
class _RankCard extends StatelessWidget {
  final UserStatsModel stats;

  const _RankCard({required this.stats});

  static String _format(int n) {
    final digits = n.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  Color get _color {
    switch (stats.currentRank) {
      case DifficultyRank.novice:
        return AppColors.categoryGardening;
      case DifficultyRank.cadet:
        return AppColors.categoryElectronics;
      case DifficultyRank.master:
        return AppColors.categoryHomeRepair;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rank = stats.currentRank;
    final isMax = rank == DifficultyRank.master;
    final target = rank == DifficultyRank.novice
        ? UserStatsModel.cadetThreshold
        : UserStatsModel.masterThreshold;
    final percent =
        isMax ? 1.0 : (stats.totalXp / target).clamp(0.0, 1.0).toDouble();
    final nextRankName = rank == DifficultyRank.novice ? 'CADET' : 'MASTER';

    return BrutalCard(
      color: _color,
      shadowOffset: 6,
      clipBehavior: Clip.hardEdge,
      child: HalftoneBackground(
        dotColor: AppColors.halftoneDot,
        dotSpacing: 8,
        dotRadius: 1.2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _WhiteTag(
                    leading: [
                      for (var i = 0; i < rank.starCount; i++)
                        const Icon(Icons.star, size: 14, color: AppColors.ink),
                    ],
                    text: 'RANK: ${rank.label.toUpperCase()}',
                  ),
                  _WhiteTag(text: stats.heroTier.title.toUpperCase()),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Text('${_format(stats.totalXp)} XP',
                      style: AppText.display(size: 44)),
                  if (!isMax)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _WhiteTag(text: '/ ${_format(target)} XP'),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              BlockProgressBar(
                  percent: percent,
                  blocks: 10,
                  fillColor: AppColors.actionYellow),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (isMax)
                    const _WhiteTag(
                      leading: [
                        Icon(Icons.emoji_events, size: 14, color: AppColors.ink)
                      ],
                      text: 'MAX RANK',
                    )
                  else ...[
                    _WhiteTag(
                      leading: const [
                        Icon(Icons.bolt, size: 14, color: AppColors.ink)
                      ],
                      text:
                          '${_format(stats.xpToNextRank ?? 0)} XP TO $nextRankName',
                    ),
                    _WhiteTag(text: '${(percent * 100).round()}% COMPLETE'),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhiteTag extends StatelessWidget {
  final String text;
  final List<Widget> leading;

  const _WhiteTag({required this.text, this.leading = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.fromBorderSide(AppTheme.tagBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...leading,
          if (leading.isNotEmpty) const SizedBox(width: 4),
          Flexible(child: Text(text, style: AppText.tag(size: 12))),
        ],
      ),
    );
  }
}

class _InProgressRow extends StatelessWidget {
  final SkillModel skill;
  final ProgressModel progress;
  final VoidCallback onOpen;

  const _InProgressRow({
    required this.skill,
    required this.progress,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final total = skill.lessons.length;
    final done = progress.completedLessonIds.length;
    final percent = progress.progressPercent(total);

    return BrutalCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: skill.accentColor,
                  border: Border.fromBorderSide(AppTheme.tagBorder),
                ),
                child: Icon(skill.icon, size: 26, color: AppColors.ink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.title.toUpperCase(),
                      style: AppText.display(size: 15, height: 1.15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${CategoryStyle.shortLabel(skill.category)} • $done of $total episodes',
                      style: AppText.caption(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BlockProgressBar(
                  percent: percent,
                  blocks: 8,
                  height: 14,
                  fillColor: skill.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              BrutalButton(
                label: 'Resume',
                icon: Icons.play_arrow,
                expand: false,
                height: 44,
                fontSize: 13,
                onPressed: onOpen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Two-column wrap of trophy badges (no fixed aspect ratio, so no overflow).
class _TrophyGrid extends StatelessWidget {
  final List<SkillModel> skills;
  final ValueChanged<SkillModel> onOpen;

  const _TrophyGrid({required this.skills, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        final columns = constraints.maxWidth >= 640 ? 3 : 2;
        final width = (constraints.maxWidth -
                gap * (columns - 1) -
                AppTheme.shadowOffset) /
            columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final skill in skills)
              SizedBox(
                  width: width,
                  child:
                      _TrophyBadge(skill: skill, onTap: () => onOpen(skill))),
          ],
        );
      },
    );
  }
}

class _TrophyBadge extends StatelessWidget {
  final SkillModel skill;
  final VoidCallback onTap;

  const _TrophyBadge({required this.skill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      onTap: onTap,
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MissionCover(
            skill: skill,
            aspectRatio: 1.6,
            iconBoxSize: 48,
            bottomRight: XpTag(xp: skill.xpReward),
          ),
          Container(height: AppTheme.borderWidth, color: AppColors.ink),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.title.toUpperCase(),
                  style: AppText.display(size: 13, height: 1.15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    border: Border.fromBorderSide(AppTheme.tagBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, size: 14, color: AppColors.ink),
                      const SizedBox(width: 4),
                      Text('COMPLETED', style: AppText.tag()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
