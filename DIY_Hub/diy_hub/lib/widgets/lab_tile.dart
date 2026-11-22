// lib/widgets/lab_tile.dart
// Tall full-width tile for the Labs tab ("Pick a lab"): flat category color,
// halftone dots, black "4 MISSIONS" tag, the full lab name (wraps at spaces
// only), a one-line blurb, three overlapping mission icons and an ENTER
// button.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../constants/category_style.dart';
import '../constants/skills_data.dart';
import 'brutal_button.dart';
import 'brutal_card.dart';
import 'halftone_background.dart';

class LabTile extends StatelessWidget {
  /// Full category name from SkillsData.
  final String category;
  final VoidCallback onTap;

  const LabTile({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final skills = SkillsData.byCategory(category);

    return BrutalCard(
      onTap: onTap,
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
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    border: Border.fromBorderSide(AppTheme.tagBorder),
                  ),
                  child: Text(
                    '${skills.length} MISSIONS',
                    style: AppText.tag(color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(category.toUpperCase(), style: AppText.display(size: 26)),
              const SizedBox(height: 8),
              Text(CategoryStyle.blurb(category), style: AppText.body(size: 14)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StackedIcons(icons: [for (final s in skills.take(3)) s.icon]),
                  const Spacer(),
                  BrutalButton(
                    label: 'Enter',
                    icon: Icons.arrow_forward,
                    style: BrutalButtonStyle.dark,
                    expand: false,
                    height: 48,
                    fontSize: 14,
                    onPressed: onTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Up to three small white icon squares, overlapping like a stack of covers.
class _StackedIcons extends StatelessWidget {
  final List<IconData> icons;

  const _StackedIcons({required this.icons});

  @override
  Widget build(BuildContext context) {
    const size = 36.0;
    const step = 26.0;
    final width = icons.isEmpty ? 0.0 : size + step * (icons.length - 1);

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < icons.length; i++)
            Positioned(
              left: i * step,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.fromBorderSide(AppTheme.tagBorder),
                ),
                child: Icon(icons[i], size: 20, color: AppColors.ink),
              ),
            ),
        ],
      ),
    );
  }
}
