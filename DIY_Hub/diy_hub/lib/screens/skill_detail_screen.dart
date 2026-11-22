// lib/screens/skill_detail_screen.dart
// MISSION DETAIL: opened when a mission card is tapped.
// Top to bottom: back button + breadcrumb, huge title, rank and tier tags,
// the black STAGE panel (status, description, main action, save), Mission
// Specs and "More in this lab", Hero Gear, Episodes, mentor tip, and a sticky
// Start / Resume / Replay button above the bottom nav (LABS highlighted).
//
// Logic is unchanged from the old version: episodes unlock one by one, the
// current episode is the first not-yet-completed one, and finishing every
// episode (in the Player) awards the XP.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../constants/category_style.dart';
import '../constants/skills_data.dart';
import '../models/progress_model.dart';
import '../models/skill_model.dart';
import '../services/progress_service.dart';
import '../services/tab_request.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/brutal_button.dart';
import '../widgets/brutal_card.dart';
import '../widgets/episode_list_item.dart';
import '../widgets/hazard_strip.dart';
import '../widgets/hero_gear_checklist.dart';
import '../widgets/key_value_row.dart';
import '../widgets/mission_cover.dart';
import '../widgets/rank_badge.dart';
import '../widgets/stage_grid.dart';
import '../widgets/stage_header.dart';
import '../widgets/status_pill.dart';
import '../widgets/sticker_label.dart';
import '../widgets/tech_tag.dart';
import 'lesson_screen.dart';

class SkillDetailScreen extends StatefulWidget {
  final SkillModel skill;

  const SkillDetailScreen({super.key, required this.skill});

  @override
  State<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  final _progressService = ProgressService();
  ProgressModel? _progress;
  bool _loading = true;

  static const _tips = [
    'Measure twice, cut once. Every maker\'s golden rule!',
    'Clamp your pieces firmly before cutting. Two clamps are twice as heroic as one!',
    'Keep your workspace tidy. A clear bench means a clear mind.',
    'Double-check polarity before powering anything on.',
    'Safety goggles are not optional. They are part of the uniform!',
    'Ask an adult for help with anything sharp, hot, or electric.',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final progress = await _progressService.getProgress(widget.skill.id);
    if (!mounted) return;
    setState(() {
      _progress = progress;
      _loading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    await _progressService.toggleFavorite(widget.skill.id);
    _load();
  }

  // ── Progress helpers ─────────────────────────────────────────────

  Set<String> get _completedIds => _progress?.completedLessonIds ?? <String>{};

  /// How many of THIS mission's episodes are done.
  int get _doneCount {
    var count = 0;
    for (final lesson in widget.skill.lessons) {
      if (_completedIds.contains(lesson.id)) count++;
    }
    return count;
  }

  MissionStatus get _status => missionStatusFor(
        completedEpisodes: _doneCount,
        totalEpisodes: widget.skill.lessons.length,
      );

  String get _statusText {
    switch (_status) {
      case MissionStatus.notStarted:
        return 'NOT STARTED';
      case MissionStatus.inProgress:
        return 'IN PROGRESS $_doneCount/${widget.skill.lessons.length}';
      case MissionStatus.completed:
        return 'COMPLETED';
    }
  }

  String get _cursorLine {
    switch (_status) {
      case MissionStatus.notStarted:
        return 'READY TO BUILD_';
      case MissionStatus.inProgress:
        return 'KEEP BUILDING_';
      case MissionStatus.completed:
        return 'MISSION CLEARED_';
    }
  }

  String get _primaryLabel {
    switch (_status) {
      case MissionStatus.notStarted:
        return 'Start mission';
      case MissionStatus.inProgress:
        return 'Resume mission';
      case MissionStatus.completed:
        return 'Replay mission';
    }
  }

  /// Index of the first episode that is not done yet (0 when all are done,
  /// so "Replay" starts from the beginning).
  int get _nextLessonIndex {
    final index = widget.skill.lessons.indexWhere((l) => !_completedIds.contains(l.id));
    return index == -1 ? 0 : index;
  }

  /// Completed episodes stay checked, the first unfinished one is the current
  /// objective, and everything after it is locked.
  EpisodeState _stateFor(int index) {
    final lessons = widget.skill.lessons;
    if (_completedIds.contains(lessons[index].id)) return EpisodeState.completed;
    final firstIncomplete = lessons.indexWhere((l) => !_completedIds.contains(l.id));
    return index == firstIncomplete ? EpisodeState.current : EpisodeState.locked;
  }

  // ── Actions ──────────────────────────────────────────────────────

  Future<void> _openLesson(int lessonIndex) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(skill: widget.skill, lessonIndex: lessonIndex),
      ),
    );
    // Reload progress in case an episode was completed (or the mission finished).
    if (result == true) _load();
  }

  void _openOther(SkillModel other) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SkillDetailScreen(skill: other)),
    );
  }

  /// Bottom nav: go back to the Home shell and show the chosen tab.
  void _goToTab(int index) {
    TabRequest.go(index);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final skill = widget.skill;
    final others =
        SkillsData.byCategory(skill.category).where((s) => s.id != skill.id).take(3).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.ink))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _buildTopRow(skill),
                    const SizedBox(height: 20),
                    Text(skill.title.toUpperCase(), style: AppText.display(size: 32)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        RankBadge(rank: skill.difficultyRank),
                        TechTag.tier(skill.minHeroTier),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildStage(skill),
                    const SizedBox(height: 28),
                    _buildInfoPanels(skill, others),
                    const SizedBox(height: 28),
                    HeroGearChecklist(
                      materials: skill.materialsList,
                      accentColor: skill.accentColor,
                    ),
                    const SizedBox(height: 28),
                    _buildEpisodes(skill),
                    const SizedBox(height: 14),
                    _buildMentorTip(skill),
                    const SizedBox(height: 28),
                    const HazardStrip(),
                  ],
                ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              decoration: const BoxDecoration(
                color: AppColors.cream,
                border: Border(top: AppTheme.border),
              ),
              child: BrutalButton(
                label: _primaryLabel,
                icon: Icons.arrow_forward,
                onPressed: _loading ? null : () => _openLesson(_nextLessonIndex),
              ),
            ),
            AppBottomNav(currentIndex: 1, onTap: _goToTab),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(SkillModel skill) {
    return Row(
      children: [
        BrutalCard(
          onTap: () => Navigator.of(context).pop(),
          shadowOffset: 3,
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.arrow_back, color: AppColors.ink),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'HOME / ${CategoryStyle.shortLabel(skill.category).toUpperCase()} / ${skill.title.toUpperCase()}',
            style: AppText.tag(size: 12, color: AppColors.muted, weight: FontWeight.w400),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// The black stage panel.
  Widget _buildStage(SkillModel skill) {
    final isFavorite = _progress?.isFavorite ?? false;

    return BrutalCard(
      color: AppColors.ink,
      shadowOffset: 6,
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StageHeader(
            label: '${CategoryStyle.shortLabel(skill.category)} · $_statusText',
            color: skill.accentColor,
            leadingIcon: CategoryStyle.icon(skill.category),
          ),
          StageGrid(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _cursorLine,
                          style: AppText.tag(size: 16, color: skill.accentColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          skill.description,
                          style: AppText.body(size: 14, color: AppColors.white),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        BrutalButton(
                          label: _primaryLabel,
                          icon: Icons.arrow_forward,
                          shadowColor: skill.accentColor,
                          onPressed: () => _openLesson(_nextLessonIndex),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: skill.accentColor,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: Center(child: CoverIconBox(icon: skill.icon, size: 56)),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.white, width: 2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${skill.estimatedMinutes} MIN · ${skill.lessons.length} EPISODES · +${skill.xpReward} XP',
                    style: AppText.tag(size: 12, color: AppColors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                BrutalButton(
                  label: isFavorite ? 'Saved' : 'Save',
                  icon: isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  iconAfterLabel: false,
                  style: BrutalButtonStyle.secondary,
                  expand: false,
                  height: 44,
                  fontSize: 13,
                  shadowColor: skill.accentColor,
                  onPressed: _toggleFavorite,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mission Specs and "More in this lab": side by side on wide screens,
  /// stacked on phones so the dotted rows stay readable.
  Widget _buildInfoPanels(SkillModel skill, List<SkillModel> others) {
    final specs = _buildSpecs(skill);
    final more = others.isEmpty ? null : _buildMore(skill, others);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (more == null) return specs;
        if (constraints.maxWidth >= 560) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: specs),
              const SizedBox(width: 16),
              Expanded(child: more),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [specs, const SizedBox(height: 18), more],
        );
      },
    );
  }

  Widget _buildSpecs(SkillModel skill) {
    final rank = skill.difficultyRank;

    return BrutalCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StickerLabel(text: 'Mission specs', fontSize: 12),
          const SizedBox(height: 10),
          KeyValueRow(label: 'Category', value: CategoryStyle.shortLabel(skill.category)),
          KeyValueRow(label: 'Tier', value: skill.minHeroTier.title),
          KeyValueRow(label: 'Difficulty', value: '${'★' * rank.starCount} ${rank.label}'),
          KeyValueRow(label: 'Time', value: '${skill.estimatedMinutes} min'),
          KeyValueRow(label: 'Episodes', value: '${skill.lessons.length}'),
          KeyValueRow(label: 'Reward', value: '+${skill.xpReward} XP', highlight: true),
        ],
      ),
    );
  }

  Widget _buildMore(SkillModel skill, List<SkillModel> others) {
    return BrutalCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StickerLabel(
            text: 'More in ${CategoryStyle.shortLabel(skill.category)}',
            color: skill.accentColor,
            fontSize: 12,
          ),
          const SizedBox(height: 8),
          for (final other in others) _MoreRow(skill: other, onTap: () => _openOther(other)),
        ],
      ),
    );
  }

  Widget _buildEpisodes(SkillModel skill) {
    final total = skill.lessons.length;
    final percent = total == 0 ? 0 : ((_doneCount / total) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const StickerLabel(text: 'Episodes'),
            const Spacer(),
            Text(
              '$percent% COMPLETE',
              style: AppText.tag(size: 12, color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < total; i++)
          EpisodeListItem(
            number: i + 1,
            title: skill.lessons[i].title,
            subtitle: skill.lessons[i].steps.isNotEmpty ? skill.lessons[i].steps.first : '',
            state: _stateFor(i),
            accentColor: skill.accentColor,
            onTap: () => _openLesson(i),
          ),
      ],
    );
  }

  Widget _buildMentorTip(SkillModel skill) {
    final tip = _tips[skill.id.hashCode.abs() % _tips.length];

    return BrutalCard(
      color: Color.alphaBlend(skill.accentColor.withValues(alpha: 0.2), AppColors.white),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.fromBorderSide(AppTheme.tagBorder),
            ),
            child: const Icon(Icons.lightbulb_outline, size: 22, color: AppColors.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MENTOR TIP', style: AppText.tag(size: 12)),
                const SizedBox(height: 4),
                Text(tip, style: AppText.body(size: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One row in "More in this lab": small colored cover, title, rank and time.
class _MoreRow extends StatelessWidget {
  final SkillModel skill;
  final VoidCallback onTap;

  const _MoreRow({required this.skill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: skill.accentColor,
                border: Border.fromBorderSide(AppTheme.tagBorder),
              ),
              child: Icon(skill.icon, size: 24, color: AppColors.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.title.toUpperCase(),
                    style: AppText.display(size: 14, height: 1.15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${skill.difficultyRank.label} · ${skill.estimatedMinutes} min',
                    style: AppText.caption(),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.ink),
          ],
        ),
      ),
    );
  }
}
