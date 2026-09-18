// lib/screens/favorites_screen.dart
// "Favorites" tab — lists every mission the user has bookmarked.
// Rendered as a tab body inside HomeScreen's shared Scaffold (no own AppBar).

import 'package:flutter/material.dart';
import '../constants/skills_data.dart';
import '../models/progress_model.dart';
import '../models/skill_model.dart';
import '../services/progress_service.dart';
import '../widgets/mission_card.dart';

class FavoritesScreen extends StatefulWidget {
  final ValueChanged<SkillModel>? onOpenSkill;

  const FavoritesScreen({super.key, this.onOpenSkill});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _progressService = ProgressService();
  Map<String, ProgressModel> _allProgress = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final progress = await _progressService.getAllProgress();
    if (!mounted) return;
    setState(() {
      _allProgress = progress;
      _loading = false;
    });
  }

  Future<void> _toggleFavorite(String skillId) async {
    await _progressService.toggleFavorite(skillId);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final favorites = SkillsData.all
        .where((skill) => _allProgress[skill.id]?.isFavorite ?? false)
        .toList();

    if (favorites.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 60),
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Tap the bookmark icon on any mission to save it here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: favorites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final skill = favorites[index];
          return MissionCard(
            skill: skill,
            isFavorite: true,
            onFavoriteToggle: () => _toggleFavorite(skill.id),
            onTap: () {
              if (widget.onOpenSkill != null) {
                widget.onOpenSkill!(skill);
              }
            },
          );
        },
      ),
    );
  }
}