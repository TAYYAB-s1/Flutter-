// lib/widgets/app_bottom_nav.dart
// Black bottom navigation with 5 tabs: HOME, LABS, STATS, SAVED, CONFIG.
// The current tab is a yellow block. Black here is a fixed design accent.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<String> labels = [
    'HOME',
    'LABS',
    'STATS',
    'SAVED',
    'CONFIG'
  ];

  static const List<IconData> _icons = [
    Icons.home_outlined,
    Icons.science_outlined,
    Icons.bar_chart,
    Icons.bookmark_border,
    Icons.tune,
  ];

  static const List<IconData> _activeIcons = [
    Icons.home,
    Icons.science,
    Icons.bar_chart,
    Icons.bookmark,
    Icons.tune,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: _NavItem(
                    label: labels[i],
                    icon: i == currentIndex ? _activeIcons[i] : _icons[i],
                    active: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.ink : AppColors.white;

    return Semantics(
      button: true,
      selected: active,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.actionYellow : AppColors.ink,
            border: active ? Border.fromBorderSide(AppTheme.tagBorder) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: fg),
              const SizedBox(height: 2),
              Text(label, style: AppText.tag(size: 11, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
