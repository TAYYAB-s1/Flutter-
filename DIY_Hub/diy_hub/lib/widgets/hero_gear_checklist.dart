// lib/widgets/hero_gear_checklist.dart
// "HERO GEAR  4/4 READY": the materials table on the Mission Detail screen.
// A black header row (ITEM / READY) followed by one row per material, each
// with a colored square bullet and a green READY tag. Materials are a plain
// list on SkillModel (there is no owned/not-owned state), so every row is
// shown as ready.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import 'brutal_card.dart';

class HeroGearChecklist extends StatelessWidget {
  final List<String> materials;

  /// The mission's category color, used for the row bullets.
  final Color accentColor;

  const HeroGearChecklist({
    super.key,
    required this.materials,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final count = materials.length;

    return BrutalCard(
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.inventory_2, size: 20, color: AppColors.ink),
                const SizedBox(width: 10),
                Expanded(
                    child: Text('HERO GEAR', style: AppText.title(size: 18))),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    border: Border.fromBorderSide(AppTheme.tagBorder),
                  ),
                  child: Text('$count/$count READY', style: AppText.tag()),
                ),
              ],
            ),
          ),
          Container(
            color: AppColors.ink,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Expanded(
                    child: Text('ITEM',
                        style: AppText.tag(color: AppColors.white))),
                Text('READY', style: AppText.tag(color: AppColors.white)),
              ],
            ),
          ),
          for (var i = 0; i < materials.length; i++)
            _GearRow(
              label: materials[i],
              accentColor: accentColor,
              showDivider: i != materials.length - 1,
            ),
        ],
      ),
    );
  }
}

class _GearRow extends StatelessWidget {
  final String label;
  final Color accentColor;
  final bool showDivider;

  const _GearRow({
    required this.label,
    required this.accentColor,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.lightDivider, width: 2))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: accentColor,
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: AppText.body(size: 14, weight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.success,
              border: Border.fromBorderSide(AppTheme.tagBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, size: 13, color: AppColors.ink),
                const SizedBox(width: 3),
                Text('READY', style: AppText.tag()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
