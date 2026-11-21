// lib/screens/favorites_screen.dart
// The SAVED tab: every mission you bookmarked, in a 2-column grid. With
// nothing saved it shows an empty state whose button jumps to the Labs tab.
// Rendered as a tab body inside HomeScreen's shared Scaffold.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../constants/skills_data.dart';
import '../models/progress_model.dart';
import '../models/skill_model.dart';
import '../services/progress_service.dart';
import '../services/tab_request.dart';
import '../widgets/empty_state.dart';
import '../widgets/hazard_strip.dart';
import '../widgets/mission_grid.dart';

class FavoritesScreen extends StatefulWidget {
  /// Opens a mission. Awaited, so this tab can refresh when you come back.
  final Future<void> Function(SkillModel)? onOpenSkill;

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

  Future<void> _toggleFavorite(SkillModel skill) async {
    await _progressService.toggleFavorite(skill.id);
    _load();
  }

  Future<void> _open(SkillModel skill) async {
    final open = widget.onOpenSkill;
    if (open == null) return;
    await open(skill);
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.ink));
    }

    final favorites = SkillsData.all
        .where((skill) => _allProgress[skill.id]?.isFavorite ?? false)
        .toList();

    return RefreshIndicator(
      color: AppColors.ink,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          Text('FAVORITES', style: AppText.display(size: 30)),
          const SizedBox(height: 8),
          Text(
            '${favorites.length} SAVED',
            style: AppText.tag(size: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          if (favorites.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: EmptyState(
                icon: Icons.bookmark_border,
                title: 'No favorites yet',
                message: 'Tap the bookmark on any mission to save it here.',
                actionLabel: 'Browse missions',
                onAction: () => TabRequest.go(1),
              ),
            )
          else
            MissionGrid(
              skills: favorites,
              progress: _allProgress,
              onOpen: _open,
              onToggleFavorite: _toggleFavorite,
            ),
          const SizedBox(height: 28),
          const HazardStrip(),
        ],
      ),
    );
  }
}
