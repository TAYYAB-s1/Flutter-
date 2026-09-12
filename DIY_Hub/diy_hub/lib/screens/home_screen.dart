// lib/screens/home_screen.dart
// NOTE: This is a functional Phase 1 placeholder so the app runs end-to-end.
// The full "Explore Missions" grid, Trending Quests, and comic styling are
// built out in the Screens phase.

import 'package:flutter/material.dart';
import '../constants/skills_data.dart';
import '../models/user_stats_model.dart';
import '../services/progress_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _progressService = ProgressService();
  int _navIndex = 0;
  UserStatsModel? _stats;

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
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _progressService.getUserStats();
    if (!mounted) return;
    setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DIY HUB'),
        actions: [
          if (_stats != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text('⚡ ${_stats!.totalXp} XP')),
            ),
        ],
      ),
      body: _buildBody(),
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
    if (_navIndex != 0) {
      return Center(
        child: Text(
          '${_navLabels[_navIndex]} screen — coming in the Screens phase',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Explore Missions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: SkillsData.allCategories.map((category) {
            final count = SkillsData.byCategory(category).length;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(category, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('$count missions', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}