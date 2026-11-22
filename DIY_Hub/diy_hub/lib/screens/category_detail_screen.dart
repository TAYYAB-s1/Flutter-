// lib/screens/category_detail_screen.dart
// One lab (category) in detail: a colored header block with totals, search,
// sort toggles (Easiest / Most XP / Shortest) and a grid of its missions.
//
// It is a pushed route with its own header and bottom nav (LABS is the
// active tab). Tapping a nav tab closes this screen and returns the tab
// index, so HomeScreen can switch to that tab.

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
import '../widgets/brutal_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/halftone_background.dart';
import '../widgets/hazard_strip.dart';
import '../widgets/mission_cover.dart';
import '../widgets/mission_grid.dart';
import 'skill_detail_screen.dart';

enum _SortMode { easiest, mostXp, shortest }

class CategoryDetailScreen extends StatefulWidget {
  /// Full category name from SkillsData.
  final String category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final _progressService = ProgressService();
  final _searchController = TextEditingController();

  UserStatsModel? _stats;
  Map<String, ProgressModel> _allProgress = {};
  _SortMode _sort = _SortMode.easiest;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final stats = await _progressService.getUserStats();
    final progress = await _progressService.getAllProgress();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _allProgress = progress;
    });
  }

  Future<void> _openSkill(SkillModel skill) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SkillDetailScreen(skill: skill)),
    );
    _load();
  }

  Future<void> _toggleFavorite(SkillModel skill) async {
    await _progressService.toggleFavorite(skill.id);
    _load();
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  /// Search filter, then the chosen sort order.
  List<SkillModel> _visibleSkills(List<SkillModel> base) {
    final query = _searchController.text.trim().toLowerCase();
    final list = base.where((s) {
      return query.isEmpty ||
          s.title.toLowerCase().contains(query) ||
          s.description.toLowerCase().contains(query);
    }).toList();

    switch (_sort) {
      case _SortMode.easiest:
        list.sort((a, b) {
          final byRank = a.difficultyRank.index.compareTo(b.difficultyRank.index);
          return byRank != 0 ? byRank : a.estimatedMinutes.compareTo(b.estimatedMinutes);
        });
        break;
      case _SortMode.mostXp:
        list.sort((a, b) => b.xpReward.compareTo(a.xpReward));
        break;
      case _SortMode.shortest:
        list.sort((a, b) => a.estimatedMinutes.compareTo(b.estimatedMinutes));
        break;
    }
    return list;
  }

  /// "CADET+" when the lab spans several ranks, otherwise just the rank.
  String _difficultyLabel(List<SkillModel> skills) {
    if (skills.isEmpty) return '-';
    var min = skills.first.difficultyRank;
    var max = skills.first.difficultyRank;
    for (final s in skills) {
      if (s.difficultyRank.index < min.index) min = s.difficultyRank;
      if (s.difficultyRank.index > max.index) max = s.difficultyRank;
    }
    return '${min.label.toUpperCase()}${min != max ? '+' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final shortName = CategoryStyle.shortLabel(category);
    final base = SkillsData.byCategory(category);
    final visible = _visibleSkills(base);

    final totalXp = base.fold<int>(0, (sum, s) => sum + s.xpReward);
    final totalMinutes = base.fold<int>(0, (sum, s) => sum + s.estimatedMinutes);

    return Scaffold(
      appBar: AppHeader(stats: _stats),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (i) => Navigator.of(context).pop(i),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
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
                  '${shortName.toUpperCase()} LAB',
                  style: AppText.title(size: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _HeaderBlock(
            category: category,
            missionCount: base.length,
            totalXp: totalXp,
            totalMinutes: totalMinutes,
            difficulty: _difficultyLabel(base),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: AppText.body(),
            decoration: InputDecoration(
              hintText: 'SEARCH IN ${shortName.toUpperCase()}',
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('SORT:', style: AppText.tag(size: 12, color: AppColors.muted)),
              _SortToggle(
                label: 'Easiest',
                selected: _sort == _SortMode.easiest,
                onTap: () => setState(() => _sort = _SortMode.easiest),
              ),
              _SortToggle(
                label: 'Most XP',
                selected: _sort == _SortMode.mostXp,
                onTap: () => setState(() => _sort = _SortMode.mostXp),
              ),
              _SortToggle(
                label: 'Shortest',
                selected: _sort == _SortMode.shortest,
                onTap: () => setState(() => _sort = _SortMode.shortest),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (visible.isEmpty)
            EmptyState(
              icon: Icons.search_off,
              title: 'No missions match',
              message: 'Try another word.',
              actionLabel: 'Clear search',
              onAction: _clearSearch,
            )
          else
            MissionGrid(
              skills: visible,
              progress: _allProgress,
              onOpen: _openSkill,
              onToggleFavorite: _toggleFavorite,
            ),
          const SizedBox(height: 24),
          const HazardStrip(),
        ],
      ),
    );
  }
}

/// Colored header block: mission count, lab icon, big name, blurb and three
/// totals (XP, time, difficulty).
class _HeaderBlock extends StatelessWidget {
  final String category;
  final int missionCount;
  final int totalXp;
  final int totalMinutes;
  final String difficulty;

  const _HeaderBlock({
    required this.category,
    required this.missionCount,
    required this.totalXp,
    required this.totalMinutes,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      color: CategoryStyle.color(category),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.ink,
                      border: Border.fromBorderSide(AppTheme.tagBorder),
                    ),
                    child: Text(
                      '$missionCount MISSIONS',
                      style: AppText.tag(color: AppColors.white),
                    ),
                  ),
                  const Spacer(),
                  CoverIconBox(icon: CategoryStyle.icon(category), size: 52),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  CategoryStyle.shortLabel(category).toUpperCase(),
                  style: AppText.display(size: 38),
                ),
              ),
              const SizedBox(height: 8),
              Text(CategoryStyle.blurb(category), style: AppText.body(size: 14)),
              const SizedBox(height: 16),
              Container(height: AppTheme.borderWidth, color: AppColors.ink),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _StatBox(label: 'XP total', value: '$totalXp')),
                  const SizedBox(width: 8),
                  Expanded(child: _StatBox(label: 'Time', value: '$totalMinutes MIN')),
                  const SizedBox(width: 8),
                  Expanded(child: _StatBox(label: 'Difficulty', value: difficulty)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border.fromBorderSide(AppTheme.tagBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppText.tag(color: AppColors.muted, weight: FontWeight.w400),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.display(size: 16)),
          ),
        ],
      ),
    );
  }
}

/// Square single-select toggle (selected = yellow with a small shadow).
class _SortToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortToggle({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Sort by $label',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.actionYellow : AppColors.white,
            border: Border.all(color: AppColors.ink, width: 2),
            boxShadow: selected
                ? const [BoxShadow(color: AppColors.ink, offset: Offset(3, 3), blurRadius: 0)]
                : const [],
          ),
          child: Text(label.toUpperCase(), style: AppText.tag(size: 12)),
        ),
      ),
    );
  }
}
