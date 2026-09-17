// lib/screens/skill_detail_screen.dart
// "PROJECT DETAIL" — shown when a mission card is tapped from Home or
// Categories. Displays mission info, required materials (Hero Gear), and
// the ordered list of episodes, each locked until the previous is done.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/skills_data.dart';
import '../models/lesson_model.dart';
import '../models/progress_model.dart';
import '../models/skill_model.dart';
import '../services/progress_service.dart';
import '../widgets/episode_list_item.dart';
import '../widgets/halftone_background.dart';
import '../widgets/hero_gear_checklist.dart';

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

  /// Determines the visual state of episode [index] based on saved progress:
  /// completed episodes are checked off, the first not-yet-completed episode
  /// is the "current objective", and everything after that is locked.
  EpisodeState _stateFor(int index) {
    final completedIds = _progress?.completedLessonIds ?? {};
    final lessons = widget.skill.lessons;
    final lesson = lessons[index];

    if (completedIds.contains(lesson.id)) return EpisodeState.completed;

    final firstIncompleteIndex = lessons.indexWhere((l) => !completedIds.contains(l.id));
    if (index == firstIncompleteIndex) return EpisodeState.current;
    return EpisodeState.locked;
  }

  void _openLesson(LessonModel lesson) {
    // TODO(Phase 3C): replace with Navigator.push to LessonScreen.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${lesson.title} — Lesson screen coming in Phase 3C')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final skill = widget.skill;
    final isFavorite = _progress?.isFavorite ?? false;
    final missionNumber = SkillsData.all.indexWhere((s) => s.id == skill.id) + 1;
    final firstLesson = skill.lessons.isNotEmpty ? skill.lessons.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROJECT DETAIL'),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border),
            color: isFavorite ? AppColors.comicYellow : null,
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _HeroBanner(skill: skill, missionNumber: missionNumber),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const _Tag(label: 'FIELD BLUEPRINT'),
                    const Spacer(),
                    _RankBadge(rank: skill.difficultyRank),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'MISSION #$missionNumber: ${skill.title.toUpperCase()}',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(skill.description, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(icon: Icons.groups, label: skill.minHeroTier.title),
                    _InfoChip(icon: Icons.schedule, label: '${skill.estimatedMinutes} mins'),
                    _InfoChip(icon: Icons.bolt, label: '+${skill.xpReward} XP'),
                  ],
                ),
                const SizedBox(height: 20),
                HeroGearChecklist(materials: skill.materialsList, accentColor: skill.accentColor),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: skill.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: firstLesson == null ? null : () => _openLesson(firstLesson),
                    child: const Text('⚡ START MISSION!'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('MISSION EPISODES', style: Theme.of(context).textTheme.titleLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: skill.accentColor, width: 1.5),
                      ),
                      child: Text(
                        '${skill.lessons.length} CHAPTERS',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(skill.lessons.length, (i) {
                  final lesson = skill.lessons[i];
                  return EpisodeListItem(
                    number: i + 1,
                    title: lesson.title,
                    subtitle: lesson.steps.isNotEmpty ? lesson.steps.first : '',
                    state: _stateFor(i),
                    accentColor: skill.accentColor,
                    onTap: () => _openLesson(lesson),
                  );
                }),
                const SizedBox(height: 4),
                _MentorTip(skillId: skill.id),
              ],
            ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final SkillModel skill;
  final int missionNumber;

  const _HeroBanner({required this.skill, required this.missionNumber});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: HalftoneBackground(
          dotColor: Colors.black.withOpacity(0.08),
          child: Container(
            color: skill.accentColor.withOpacity(0.45),
            child: Stack(
              children: [
                Center(child: Icon(skill.icon, size: 72, color: Colors.black87)),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '⚡ LAB DISCOVERY #$missionNumber',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final DifficultyRank rank;

  const _RankBadge({required this.rank});

  Color _color() {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black87, width: 1.5),
      ),
      child: Text(
        '${'★' * rank.starCount} RANK: ${rank.label.toUpperCase()}',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MentorTip extends StatelessWidget {
  final String skillId;

  const _MentorTip({required this.skillId});

  static const _tips = [
    'Measure twice, cut once — every maker\'s golden rule!',
    'Clamp your pieces firmly before cutting. Two clamps are twice as heroic as one!',
    'Keep your workspace tidy — a clear bench means a clear mind.',
    'Double-check polarity before powering anything on.',
    'Safety goggles aren\'t optional gear — they\'re part of the uniform!',
    'Ask an adult for help with anything sharp, hot, or electric.',
  ];

  @override
  Widget build(BuildContext context) {
    final tip = _tips[skillId.hashCode.abs() % _tips.length];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.comicYellow.withOpacity(0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.comicYellow, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.smart_toy, color: AppColors.comicOrange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LAB ROBOT MENTOR TIP',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text('"$tip"', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}