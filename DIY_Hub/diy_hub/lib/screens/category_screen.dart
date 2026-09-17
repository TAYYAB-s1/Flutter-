// lib/screens/category_screen.dart
// "Categories" tab — full searchable/filterable mission list.
// Rendered as a tab body inside HomeScreen's shared Scaffold (no own AppBar).

import 'package:flutter/material.dart';
import '../constants/skills_data.dart';
import '../models/progress_model.dart';
import '../models/skill_model.dart';
import '../services/progress_service.dart';
import '../widgets/mission_card.dart';

class CategoryScreen extends StatefulWidget {
  final String initialCategory;
  final ValueChanged<SkillModel>? onOpenSkill;

  const CategoryScreen({
    super.key,
    this.initialCategory = 'All',
    this.onOpenSkill,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  static const _beginnerSafeFilter = 'Beginner Safe';

  final _progressService = ProgressService();
  final _searchController = TextEditingController();

  late String _selectedFilter = widget.initialCategory;
  String _searchQuery = '';
  Map<String, ProgressModel> _progressBySkill = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final all = await _progressService.getAllProgress();
    if (!mounted) return;
    setState(() => _progressBySkill = all);
  }

  Future<void> _toggleFavorite(String skillId) async {
    await _progressService.toggleFavorite(skillId);
    await _loadProgress();
  }

  List<SkillModel> get _filteredSkills {
    Iterable<SkillModel> result = SkillsData.all;

    if (_selectedFilter == _beginnerSafeFilter) {
      result = result.where((s) => s.difficultyRank == DifficultyRank.novice);
    } else if (_selectedFilter != 'All') {
      result = result.where((s) => s.category == _selectedFilter);
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      result = result.where(
        (s) => s.title.toLowerCase().contains(query) || s.description.toLowerCase().contains(query),
      );
    }

    return result.toList();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['All', _beginnerSafeFilter, ...SkillsData.allCategories];
    final skills = _filteredSkills;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search circuits, soldering, robots...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final label = filters[index];
              final isSelected = _selectedFilter == label;
              return ChoiceChip(
                label: Text(label == 'All' ? 'All Missions (${SkillsData.all.length})' : label),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedFilter = label),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: skills.isEmpty
              ? _EmptyState(query: _searchQuery)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: skills.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final skill = skills[index];
                    final isFavorite = _progressBySkill[skill.id]?.isFavorite ?? false;
                    return MissionCard(
                      skill: skill,
                      isFavorite: isFavorite,
                      onFavoriteToggle: () => _toggleFavorite(skill.id),
                      onTap: () {
                        if (widget.onOpenSkill != null) {
                          widget.onOpenSkill!(skill);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mission Detail — coming in Phase 3')),
                          );
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;

  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Theme.of(context).textTheme.bodySmall?.color),
            const SizedBox(height: 12),
            Text(
              query.isEmpty ? 'No missions match this filter' : 'No missions found for "$query"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}