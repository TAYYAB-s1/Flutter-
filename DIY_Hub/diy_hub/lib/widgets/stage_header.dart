// lib/widgets/stage_header.dart
// The colored top bar of a "stage" panel (Mission Detail and Mission
// Player): a status line in monospace such as
// "ROBOTICS · IN PROGRESS 2/4", with an optional leading icon and trailing
// widget. The bar color is the category color.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

class StageHeader extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? leadingIcon;
  final Widget? trailing;

  const StageHeader({
    super.key,
    required this.label,
    required this.color,
    this.leadingIcon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        border: const Border(bottom: AppTheme.border),
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 16, color: AppColors.ink),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: AppText.tag(size: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
