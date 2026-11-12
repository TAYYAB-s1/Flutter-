// lib/widgets/xp_tag.dart
// Black tag with a yellow bolt: "+150 XP". Shown on mission cards and covers.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

class XpTag extends StatelessWidget {
  final int xp;

  const XpTag({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.ink,
        border: Border.fromBorderSide(AppTheme.tagBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 14, color: AppColors.actionYellow),
          const SizedBox(width: 2),
          Text('+$xp XP', style: AppText.tag(color: AppColors.white)),
        ],
      ),
    );
  }
}