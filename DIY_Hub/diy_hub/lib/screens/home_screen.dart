// lib/screens/home_screen.dart
// Acts as the app's main navigation shell: shared AppBar + bottom nav,
// with the Home tab showing the Continue Learning banner, the Explore
// Missions category grid, and Trending Quests. Other tabs (Categories,
// Progress, Favorites, Settings) are swapped in as the body changes.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/skills_data.dart';
import '../models/progress_model.dart';
import '../models/skill_model.dart';
import '../models/user_stats_model.dart';
import '../services/progress_service.dart';
import '../widgets/category_tile.dart';
import '../widgets/mission_card.dart';
import '../widgets/power_meter_bar.dart';
import '../widgets/xp_rank_badge.dart';
import 'category_screen.dart';
import 'favorites_screen.dart';
import 'progress_screen.dart';
import 'skill_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _progressService = ProgressService();

  int _navIndex = 0;
  String _categoryFilter = 'All';

  UserStatsModel? _stats;
  Map<String, ProgressModel> _allProgress = {};

  static const _navLabels = ['Home', 'Categories', 'Progress', 'Favorites', 'Settings'];
  static const _navIcons = [
    Icons.home,
    Icons.grid_view,
    Icons.emoji_events,
    Icons.bookmark,
    Icons.settings,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
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

  void _openCategoryTab(String category) {
    setState(() {
      _categoryFilter = category;
      _navIndex = 1;
    });
  }

  Future<void> _openSkill(SkillModel skill) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SkillDetailScreen(skill: skill)),
    );
    // Refresh in case favorites/progress changed while on the detail screen.
    _loadData();
  }

  /// Finds a skill that's been started but not finished, for the
  /// "Continue Learning" banner. Returns null if nothing is in progress.
  MapEntry<SkillModel, ProgressModel>? get _continueSkill {
    for (final entry in _allProgress.entries) {
      final progress = entry.value;
      if (progress.completedLessonIds.isNotEmpty && !progress.isCompleted) {
        final skill = SkillsData.all.where((s) => s.id == entry.key).firstOrNull;
        if (skill != null) return MapEntry(skill, progress);
      }
    }
    return null;
  }

  List<SkillModel> get _trendingSkills {
    final sorted = [...SkillsData.all]..sort((a, b) => b.xpReward.compareTo(a.xpReward));
    return sorted.take(4).toList();
  }

  static const _categoryIcons = {
    SkillsData.electronics: Icons.bolt,
    SkillsData.homeRepair: Icons.build,
    SkillsData.woodcraft: Icons.carpenter,
    SkillsData.cookingLab: Icons.restaurant,
    SkillsData.robotics: Icons.smart_toy,
    SkillsData.gardening: Icons.eco,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.comicYellow),
            const SizedBox(width: 6),
            Text('DIY', style: Theme.of(context).textTheme.titleLarge),
            Text(
              'HUB',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.comicBlue),
            ),
          ],
        ),
        actions: [
          if (_stats != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: XpRankBadge(xp: _stats!.totalXp)),
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() {
              _categoryFilter = 'All';
              _navIndex = 1;
            }),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        items: List.generate(
          _navLabels.length,
          (i) => BottomNavigationBarItem(icon: Icon(_navIcons[i]), label: _navLabels[i]),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return CategoryScreen(
          key: ValueKey(_categoryFilter),
          initialCategory: _categoryFilter,
          onOpenSkill: _openSkill,
        );
      case 2:
        return ProgressScreen(onOpenSkill: _openSkill);
      case 3:
        return FavoritesScreen(onOpenSkill: _openSkill);
      default:
        return Center(
          child: Text(
            '${_navLabels[_navIndex]} screen — coming in a later phase',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
    }
  }

  Widget _buildHomeTab() {
    final continueEntry = _continueSkill;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (continueEntry != null) ...[
            _ContinueLearningBanner(
              skill: continueEntry.key,
              progress: continueEntry.value,
              onResume: () => _openSkill(continueEntry.key),
            ),
            const SizedBox(height: 24),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Explore Missions', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () => _openCategoryTab('All'),
                child: const Text('SEE ALL'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: SkillsData.allCategories.map((category) {
              final count = SkillsData.byCategory(category).length;
              return CategoryTile(
                title: category,
                subtitle: '$count missions',
                icon: _categoryIcons[category] ?? Icons.category,
                color: SkillsData.byCategory(category).first.accentColor,
                onTap: () => _openCategoryTab(category),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Trending Quests', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _trendingSkills.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final skill = _trendingSkills[index];
                final isFavorite = _allProgress[skill.id]?.isFavorite ?? false;
                return SizedBox(
                  width: 240,
                  child: MissionCard(
                    skill: skill,
                    burstLabel: index == 0 ? 'HOT!' : null,
                    isFavorite: isFavorite,
                    onFavoriteToggle: () async {
                      await _progressService.toggleFavorite(skill.id);
                      _loadData();
                    },
                    onTap: () => _openSkill(skill),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueLearningBanner extends StatelessWidget {
  final SkillModel skill;
  final ProgressModel progress;
  final VoidCallback onResume;

  const _ContinueLearningBanner({
    required this.skill,
    required this.progress,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final percent = progress.progressPercent(skill.lessons.length);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.comicRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'MISSION IN PROGRESS',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: skill.accentColor,
                  child: Icon(skill.icon, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(skill.title, style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 14),
            PowerMeterBar(percent: percent, fillColor: skill.accentColor),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.completedLessonIds.length}/${skill.lessons.length} episodes done',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                ElevatedButton(onPressed: onResume, child: const Text('RESUME!')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}