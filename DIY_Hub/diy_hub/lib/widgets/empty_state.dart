// lib/widgets/empty_state.dart
// Shown when a list has nothing to show: a flat icon box, a title, a hint
// and an optional action button.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import 'brutal_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.fromBorderSide(AppTheme.border),
                boxShadow: AppTheme.hardShadow(),
              ),
              child: Icon(icon, size: 44, color: AppColors.ink),
            ),
            const SizedBox(height: 24),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppText.title(size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.bodyMuted(),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              BrutalButton(
                label: actionLabel!,
                onPressed: onAction,
                style: BrutalButtonStyle.secondary,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
