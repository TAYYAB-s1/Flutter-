// lib/widgets/episode_list_item.dart
// One numbered row in the "Episodes" list on the Mission Detail screen.
//   completed = green DONE tag
//   current   = category-colored border/number and a CURRENT tag
//   upcoming  = plain row with a chevron
//   locked    = gray, lock icon, not tappable
// Spacing below the row is built in, so callers can just stack them.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import 'brutal_card.dart';

enum EpisodeState { completed, current, upcoming, locked }

class EpisodeListItem extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final EpisodeState state;
  final Color accentColor;
  final VoidCallback? onTap;

  const EpisodeListItem({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.state,
    required this.accentColor,
    this.onTap,
  });

  bool get _locked => state == EpisodeState.locked;
  bool get _current => state == EpisodeState.current;

  Color get _background {
    if (_locked) {
      return Color.alphaBlend(AppColors.locked.withValues(alpha: 0.4), AppColors.cream);
    }
    if (_current) {
      return Color.alphaBlend(accentColor.withValues(alpha: 0.22), AppColors.white);
    }
    return AppColors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, right: 4),
      child: Semantics(
        button: !_locked,
        enabled: !_locked,
        label: 'Episode $number, $title',
        child: BrutalCard(
          onTap: _locked ? null : onTap,
          color: _background,
          shadowOffset: _locked ? 0 : (_current ? 6 : 4),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NumberBadge(number: number, state: state, accentColor: accentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: AppText.display(
                        size: 15,
                        height: 1.15,
                        color: _locked ? AppColors.muted : AppColors.ink,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppText.caption(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StateTag(state: state, accentColor: accentColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int number;
  final EpisodeState state;
  final Color accentColor;

  const _NumberBadge({
    required this.number,
    required this.state,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color textColor;
    switch (state) {
      case EpisodeState.completed:
        fill = AppColors.success;
        textColor = AppColors.ink;
        break;
      case EpisodeState.current:
        fill = accentColor;
        textColor = AppColors.ink;
        break;
      case EpisodeState.upcoming:
        fill = AppColors.white;
        textColor = AppColors.ink;
        break;
      case EpisodeState.locked:
        fill = AppColors.locked;
        textColor = AppColors.muted;
        break;
    }

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        border: Border.fromBorderSide(AppTheme.tagBorder),
      ),
      child: state == EpisodeState.completed
          ? const Icon(Icons.check, size: 22, color: AppColors.ink)
          : Text('$number', style: AppText.display(size: 16, color: textColor)),
    );
  }
}

class _StateTag extends StatelessWidget {
  final EpisodeState state;
  final Color accentColor;

  const _StateTag({required this.state, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case EpisodeState.upcoming:
        return const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.chevron_right, size: 24, color: AppColors.ink),
        );
      case EpisodeState.completed:
        return _tag(AppColors.success, Icons.check, 'DONE', AppColors.ink);
      case EpisodeState.current:
        return _tag(accentColor, Icons.play_arrow, 'CURRENT', AppColors.ink);
      case EpisodeState.locked:
        return _tag(AppColors.locked, Icons.lock, 'LOCKED', AppColors.muted);
    }
  }

  Widget _tag(Color color, IconData icon, String text, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        border: Border.fromBorderSide(AppTheme.tagBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 3),
          Text(text, style: AppText.tag(color: fg)),
        ],
      ),
    );
  }
}
