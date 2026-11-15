// lib/widgets/category_tile.dart
// Compact lab tile for the Home "Pick a lab" bento grid: flat category
// color, halftone dots, icon box, black "4 MISSIONS" tag and the lab name.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../constants/category_style.dart';
import 'brutal_card.dart';
import 'halftone_background.dart';
import 'mission_cover.dart';

class CategoryTile extends StatelessWidget {
  /// Full category name from SkillsData (e.g. "Electronics & Gadget Lab").
  final String category;
  final int missionCount;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.category,
    required this.missionCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      onTap: onTap,
      color: CategoryStyle.color(category),
      clipBehavior: Clip.hardEdge,
      child: HalftoneBackground(
        dotColor: AppColors.halftoneDot,
        dotSpacing: 8,
        dotRadius: 1.2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CoverIconBox(icon: CategoryStyle.icon(category), size: 40),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.ink,
                            border: Border.fromBorderSide(AppTheme.tagBorder),
                          ),
                          child: Text(
                            '$missionCount MISSIONS',
                            style: AppText.tag(color: AppColors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // One line that scales down instead of breaking a word in half.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  CategoryStyle.shortLabel(category).toUpperCase(),
                  style: AppText.display(size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
