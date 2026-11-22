// lib/screens/category_screen.dart
// The LABS tab: "PICK A LAB". Six tall colored tiles, one per category,
// with a search field. Tapping a tile (or its ENTER button) calls
// [onOpenCategory], which opens the Category Detail screen.
// Rendered as a tab body inside HomeScreen's shared Scaffold.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../constants/category_style.dart';
import '../constants/skills_data.dart';
import '../widgets/empty_state.dart';
import '../widgets/hazard_strip.dart';
import '../widgets/lab_tile.dart';

class CategoryScreen extends StatefulWidget {
  final ValueChanged<String> onOpenCategory;

  const CategoryScreen({super.key, required this.onOpenCategory});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  /// A lab matches if the query is in its name, blurb, or any of its
  /// mission titles.
  bool _matches(String category, String query) {
    if (query.isEmpty) return true;
    if (category.toLowerCase().contains(query)) return true;
    if (CategoryStyle.blurb(category).toLowerCase().contains(query)) return true;
    return SkillsData.byCategory(category).any((s) => s.title.toLowerCase().contains(query));
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final labs = SkillsData.allCategories.where((c) => _matches(c, query)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        Text('PICK A LAB', style: AppText.display(size: 30)),
        const SizedBox(height: 8),
        Text(
          '${SkillsData.allCategories.length} LABS · ${SkillsData.all.length} MISSIONS',
          style: AppText.tag(size: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          style: AppText.body(),
          decoration: InputDecoration(
            hintText: 'SEARCH LABS OR MISSIONS',
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
        const SizedBox(height: 24),
        if (labs.isEmpty)
          EmptyState(
            icon: Icons.search_off,
            title: 'No labs match',
            message: 'Try another word.',
            actionLabel: 'Clear search',
            onAction: _clearSearch,
          )
        else
          for (final category in labs)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: LabTile(
                category: category,
                onTap: () => widget.onOpenCategory(category),
              ),
            ),
        const SizedBox(height: 4),
        const HazardStrip(),
      ],
    );
  }
}
