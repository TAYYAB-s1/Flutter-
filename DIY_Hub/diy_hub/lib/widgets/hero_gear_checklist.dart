// lib/widgets/hero_gear_checklist.dart
// Materials checklist shown on the Skill Detail screen, styled like the
// mockup's "HERO GEAR REQUIRED — 5/5 READY" card. Since materials are just
// a flat list on SkillModel (no per-item owned/unowned state), every item
// is shown as checked/ready — this widget is the visual shell for that.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class HeroGearChecklist extends StatelessWidget {
  final List<String> materials;
  final Color accentColor;

  const HeroGearChecklist({
    super.key,
    required this.materials,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark ? AppColors.darkOutline : AppColors.lightOutline;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outline, width: 2.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, size: 18, color: accentColor),
                    const SizedBox(width: 8),
                    Text('HERO GEAR REQUIRED', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${materials.length}/${materials.length} READY',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: outline.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: materials.map((item) => _GearRow(label: item, accentColor: accentColor)).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _GearRow extends StatelessWidget {
  final String label;
  final Color accentColor;

  const _GearRow({required this.label, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black87, width: 1.5),
            ),
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}