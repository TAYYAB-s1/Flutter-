// lib/screens/widget_gallery_screen.dart
// DEV ONLY: shows every shared widget from Phase A in one scrolling page so
// you can check the look on a device. It is not part of the real app flow.
//
// To open it, temporarily change `home:` in lib/main.dart to
//   home: const WidgetGalleryScreen(),
// and put the original line back when you are done.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../constants/skills_data.dart';
import '../models/skill_model.dart';
import '../models/user_stats_model.dart';
import 'app_bottom_nav.dart';
import 'app_header.dart';
import 'block_progress_bar.dart';
import 'brutal_button.dart';
import 'brutal_card.dart';
import 'empty_state.dart';
import 'hazard_strip.dart';
import 'key_value_row.dart';
import 'mission_cover.dart';
import 'rank_badge.dart';
import 'segmented_step_bar.dart';
import 'stage_header.dart';
import 'status_pill.dart';
import 'sticker_label.dart';
import 'tech_tag.dart';
import 'xp_tag.dart';

class WidgetGalleryScreen extends StatefulWidget {
  const WidgetGalleryScreen({super.key});

  @override
  State<WidgetGalleryScreen> createState() => _WidgetGalleryScreenState();
}

class _WidgetGalleryScreenState extends State<WidgetGalleryScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final skill = SkillsData.all.firstWhere((s) => s.id == 'solar_mini_rover');

    return Scaffold(
      appBar: const AppHeader(
        stats: UserStatsModel(totalXp: 750, heroTier: HeroTier.teens),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('WIDGET GALLERY', style: AppText.display(size: 28)),
          const SizedBox(height: 4),
          Text('Phase A shared widgets', style: AppText.bodyMuted()),
          const SizedBox(height: 24),
          const StickerLabel(text: 'Buttons'),
          const SizedBox(height: 12),
          BrutalButton(
              label: 'Start mission',
              icon: Icons.arrow_forward,
              onPressed: () {}),
          BrutalButton(
            label: 'Browse missions',
            style: BrutalButtonStyle.secondary,
            onPressed: () {},
          ),
          BrutalButton(
              label: 'Reset',
              style: BrutalButtonStyle.danger,
              onPressed: () {}),
          const BrutalButton(label: 'Disabled', onPressed: null),
          BrutalButton(label: 'Saving', loading: true, onPressed: () {}),
          const SizedBox(height: 16),
          const StickerLabel(text: 'Tags and badges'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TechTag.time(35),
              TechTag.tier(HeroTier.teens),
              TechTag.episodes(4),
              const XpTag(xp: 300),
              const RankBadge(rank: DifficultyRank.novice),
              const RankBadge(rank: DifficultyRank.cadet),
              const RankBadge(rank: DifficultyRank.master),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              StatusPill(status: MissionStatus.notStarted),
              StatusPill(
                status: MissionStatus.inProgress,
                completedEpisodes: 2,
                totalEpisodes: 4,
              ),
              StatusPill(status: MissionStatus.completed),
            ],
          ),
          const SizedBox(height: 24),
          const StickerLabel(text: 'Card + cover'),
          const SizedBox(height: 12),
          BrutalCard(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MissionCover(
                  skill: skill,
                  topLeft: RankBadge(rank: skill.difficultyRank),
                  topRight: XpTag(xp: skill.xpReward),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(skill.title.toUpperCase(),
                          style: AppText.cardTitle()),
                      const SizedBox(height: 4),
                      Text('Robotics • ${skill.lessons.length} Episodes',
                          style: AppText.caption()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const StickerLabel(text: 'Progress'),
          const SizedBox(height: 12),
          const BlockProgressBar(percent: 0.5),
          const SizedBox(height: 12),
          const BlockProgressBar(
              percent: 0.33, blocks: 6, fillColor: AppColors.categoryRobotics),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.ink,
            child: const SegmentedStepBar(total: 3, current: 2),
          ),
          const SizedBox(height: 24),
          const StickerLabel(text: 'Stage + specs'),
          const SizedBox(height: 12),
          BrutalCard(
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                const StageHeader(
                  label: 'Robotics · In progress 2/4',
                  color: AppColors.categoryRobotics,
                  leadingIcon: Icons.smart_toy,
                ),
                Container(
                  color: AppColors.ink,
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: Text(
                    'KEEP BUILDING_',
                    style: AppText.tag(size: 16, color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const BrutalCard(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                KeyValueRow(label: 'Category', value: 'Robotics'),
                KeyValueRow(label: 'Time', value: '35 min'),
                KeyValueRow(label: 'Reward', value: '+300 XP', highlight: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const StickerLabel(text: 'Empty state'),
          const EmptyState(
            icon: Icons.bookmark_border,
            title: 'No favorites yet',
            message: 'Tap the bookmark on any mission to save it here.',
          ),
          const SizedBox(height: 16),
          const HazardStrip(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
