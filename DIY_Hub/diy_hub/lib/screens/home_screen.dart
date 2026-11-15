// lib/screens/home_screen.dart
// The main shell: black header, the 5-tab bottom nav (HOME, LABS, STATS,
// SAVED, CONFIG) and the Home tab itself.
//

// Home tab (top to bottom): headline + stat line, search + random-mission
// dice, "Pick a lab" bento grid, Featured Today, Continue (only if a mission
// is in progress), "Start here" row for the user's Hero Tier.
//
// The other tabs still show the previous screens until they are restyled in
// later phases (Stats / Saved / Config: Phase E). Labs is done (Phase C).

import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../constants/category_style.dart';
import '../constants/skills_data.dart';
import '../models/progress_model.dart';
import '../models/skill_model.dart';
import '../models/user_stats_model.dart';
import '../services/progress_service.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_header.dart';
import '../widgets/block_progress_bar.dart';
import '../widgets/brutal_button.dart';
import '../widgets/brutal_card.dart';
import '../widgets/category_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/hazard_strip.dart';
import '../widgets/mission_card.dart';
import '../widgets/mission_cover.dart';
import '../widgets/mission_grid.dart';
import '../widgets/rank_badge.dart';
import '../widgets/status_pill.dart';
import '../widgets/sticker_label.dart';
import '../widgets/tech_tag.dart';
import '../widgets/xp_tag.dart';
import 'category_detail_screen.dart';
import 'category_screen.dart';
import 'favorites_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';
import 'skill_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _progressService = ProgressService();
  final _searchController = TextEditingController();
  final _startHereController = ScrollController();

  int _navIndex = 0;

  UserStatsModel? _stats;
  Map<String, ProgressModel> _allProgress = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _startHereController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final stats = await _progressService.getUserStats();
    final progress = await _progressService.getAllProgress();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _allProgress = progress;
    });
  }

  // ── Actions ──────────────────────────────────────────────────────

  /// Opens a lab's detail screen. If the user taps a bottom-nav tab there,
  /// the detail screen closes and returns that tab index, which we switch to.
  Future<void> _openCategory(String category) async {
    final tab = await Navigator.of(context).push<int>(
      MaterialPageRoute(
          builder: (_) => CategoryDetailScreen(category: category)),
    );
    _loadData();
    if (tab != null && mounted) setState(() => _navIndex = tab);
  }

  Future<void> _openSkill(SkillModel skill) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SkillDetailScreen(skill: skill)),
    );
    // Refresh in case favorites/progress changed while on the detail screen.
    _loadData();
  }

  Future<void> _toggleFavorite(SkillModel skill) async {
    await _progressService.toggleFavorite(skill.id);
    _loadData();
  }

  void _openRandomMission() {
    final skill = SkillsData.all[Random().nextInt(SkillsData.all.length)];
    _openSkill(skill);
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  void _scrollStartHere(int direction) {
    if (!_startHereController.hasClients) return;
    final max = _startHereController.position.maxScrollExtent;
    final target = (_startHereController.offset + direction * 234)
        .clamp(0.0, max)
        .toDouble();
    _startHereController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // ── Derived data ─────────────────────────────────────────────────

  /// Missions suited to the user's Hero Tier (falls back to everything).
  List<SkillModel> get _tierPool {
    final tier = _stats?.heroTier;
    final pool = tier == null
        ? <SkillModel>[]
        : SkillsData.all.where((s) => s.minHeroTier == tier).toList();
    return pool.isEmpty ? SkillsData.all : pool;
  }

  /// Offline "mission of the day": rotates through the tier pool by day.
  SkillModel get _featured {
    final pool = _tierPool;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return pool[dayOfYear % pool.length];
  }

  /// A mission that has been started but not finished, or null.
  SkillModel? get _continueSkill {
    for (final skill in SkillsData.all) {
      final progress = _allProgress[skill.id];
      if (progress != null &&
          progress.completedLessonIds.isNotEmpty &&
          !progress.isCompleted) {
        return skill;
      }
    }
    return null;
  }

  int _doneEpisodes(SkillModel skill) =>
      _allProgress[skill.id]?.completedLessonIds.length ?? 0;

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(stats: _stats),
      body: _buildBody(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return CategoryScreen(onOpenCategory: _openCategory);
      case 2:
        return ProgressScreen(onOpenSkill: _openSkill);
      case 3:
        return FavoritesScreen(onOpenSkill: _openSkill);
      default:
        return const SettingsScreen();
    }
  }

  Widget _buildHomeTab() {
    final query = _searchController.text.trim().toLowerCase();

    return RefreshIndicator(
      color: AppColors.ink,
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          Text('BUILD REAL THINGS.\nLEVEL UP.',
              style: AppText.display(size: 28)),
          const SizedBox(height: 8),
          Text(
            '${SkillsData.all.length} MISSIONS · ${SkillsData.allCategories.length} LABS · NO ACCOUNT NEEDED',
            style: AppText.tag(size: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          _buildSearchRow(),
          const SizedBox(height: 24),
          if (query.isNotEmpty)
            ..._buildSearchResults(query)
          else
            ..._buildSections(),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            style: AppText.body(),
            decoration: InputDecoration(
              hintText: 'SEARCH MISSIONS',
              prefixIcon: const Icon(Icons.search, color: AppColors.ink),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close, color: AppColors.ink),
                      onPressed: _clearSearch,
                    ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: 'Random mission',
          child: BrutalCard(
            color: AppColors.actionYellow,
            onTap: _openRandomMission,
            child: const SizedBox(
              width: 52,
              height: 52,
              child: Icon(Icons.casino, size: 26, color: AppColors.ink),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSearchResults(String query) {
    final results = SkillsData.all.where((s) {
      return s.title.toLowerCase().contains(query) ||
          s.description.toLowerCase().contains(query) ||
          CategoryStyle.shortLabel(s.category).toLowerCase().contains(query);
    }).toList();

    if (results.isEmpty) {
      return [
        EmptyState(
          icon: Icons.search_off,
          title: 'No missions match',
          message: 'Try another word or pick a lab.',
          actionLabel: 'Clear search',
          onAction: _clearSearch,
        ),
      ];
    }

    return [
      Align(
        alignment: Alignment.centerLeft,
        child: StickerLabel(
            text:
                '${results.length} ${results.length == 1 ? 'result' : 'results'}'),
      ),
      const SizedBox(height: 14),
      MissionGrid(
        skills: results,
        progress: _allProgress,
        onOpen: _openSkill,
        onToggleFavorite: _toggleFavorite,
      ),
    ];
  }

  List<Widget> _buildSections() {
    final featured = _featured;
    final continueSkill = _continueSkill;
    final tier = _stats?.heroTier;
    final startHere = _tierPool.take(8).toList();

    return [
      const Align(
          alignment: Alignment.centerLeft,
          child: StickerLabel(text: 'Pick a lab')),
      const SizedBox(height: 14),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        clipBehavior: Clip.none, // let the hard shadows show at the edges
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.25,
        children: [
          for (final category in SkillsData.allCategories)
            CategoryTile(
              category: category,
              missionCount: SkillsData.byCategory(category).length,
              onTap: () => _openCategory(category),
            ),
        ],
      ),
      const SizedBox(height: 28),
      const Align(
          alignment: Alignment.centerLeft,
          child: StickerLabel(text: 'Featured today')),
      const SizedBox(height: 14),
      _buildFeaturedCard(featured),
      if (continueSkill != null) ...[
        const SizedBox(height: 28),
        const Align(
            alignment: Alignment.centerLeft,
            child: StickerLabel(text: 'Continue')),
        const SizedBox(height: 14),
        _buildContinueCard(continueSkill),
      ],
      const SizedBox(height: 28),
      Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: StickerLabel(
                text:
                    tier == null ? 'Start here' : 'Start here · ${tier.title}',
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ArrowButton(
              icon: Icons.chevron_left,
              label: 'Scroll left',
              onTap: () => _scrollStartHere(-1)),
          const SizedBox(width: 8),
          _ArrowButton(
              icon: Icons.chevron_right,
              label: 'Scroll right',
              onTap: () => _scrollStartHere(1)),
        ],
      ),
      const SizedBox(height: 14),
      SingleChildScrollView(
        controller: _startHereController,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(right: 4, bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final skill in startHere)
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: SizedBox(
                  width: 220,
                  child: MissionCard(
                    skill: skill,
                    isFavorite: _allProgress[skill.id]?.isFavorite ?? false,
                    progressPercent: _allProgress[skill.id]
                            ?.progressPercent(skill.lessons.length) ??
                        0,
                    completed: _allProgress[skill.id]?.isCompleted ?? false,
                    onFavoriteToggle: () => _toggleFavorite(skill),
                    onTap: () => _openSkill(skill),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 28),
      const HazardStrip(),
      const SizedBox(height: 12),
      Center(
        child: Text(
          '44 49 59 48 55 42',
          style: AppText.tag(color: AppColors.muted, weight: FontWeight.w400),
        ),
      ),
    ];
  }

  Widget _buildFeaturedCard(SkillModel skill) {
    final done = _doneEpisodes(skill);
    final status = missionStatusFor(
      completedEpisodes: done,
      totalEpisodes: skill.lessons.length,
    );
    final buttonLabel = status == MissionStatus.completed
        ? 'Replay mission'
        : (status == MissionStatus.inProgress
            ? 'Resume mission'
            : 'Start mission');

    return BrutalCard(
      onTap: () => _openSkill(skill),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MissionCover(
            skill: skill,
            aspectRatio: 1.9,
            iconBoxSize: 72,
            topLeft: RankBadge(rank: skill.difficultyRank),
            topRight: XpTag(xp: skill.xpReward),
          ),
          Container(height: AppTheme.borderWidth, color: AppColors.ink),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${CategoryStyle.shortLabel(skill.category)} · ${skill.lessons.length} episodes'
                      .toUpperCase(),
                  style: AppText.tag(size: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 6),
                Text(skill.title.toUpperCase(), style: AppText.title(size: 24)),
                const SizedBox(height: 8),
                Text(
                  skill.description,
                  style: AppText.bodyMuted(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TechTag.time(skill.estimatedMinutes),
                    TechTag.tier(skill.minHeroTier),
                  ],
                ),
                const SizedBox(height: 16),
                BrutalButton(
                  label: buttonLabel,
                  icon: Icons.arrow_forward,
                  onPressed: () => _openSkill(skill),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueCard(SkillModel skill) {
    final done = _doneEpisodes(skill);
    final total = skill.lessons.length;
    final percent = _allProgress[skill.id]?.progressPercent(total) ?? 0;

    return BrutalCard(
      onTap: () => _openSkill(skill),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CoverIconBox(icon: skill.icon, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.title.toUpperCase(),
                      style: AppText.cardTitle(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text('$done of $total episodes done',
                        style: AppText.caption()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlockProgressBar(
              percent: percent, blocks: 8, fillColor: skill.accentColor),
          const SizedBox(height: 14),
          BrutalButton(
            label: 'Resume',
            icon: Icons.play_arrow,
            height: 48,
            onPressed: () => _openSkill(skill),
          ),
        ],
      ),
    );
  }
}

/// Small square arrow button for the "Start here" row.
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ArrowButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: BrutalCard(
        onTap: onTap,
        shadowOffset: 3,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 26, color: AppColors.ink),
        ),
      ),
    );
  }
}
