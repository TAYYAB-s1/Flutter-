// lib/widgets/sticker_label.dart
// A filled block label with an ink border, e.g. "START HERE" (black with
// white text) or a category-colored "ROBOTICS" label.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

class StickerLabel extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;
  final IconData? icon;
  final double fontSize;

  const StickerLabel({
    super.key,
    required this.text,
    this.color = AppColors.ink,
    this.textColor,
    this.icon,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    final fg =
        textColor ?? (color == AppColors.ink ? AppColors.white : AppColors.ink);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        border: Border.fromBorderSide(AppTheme.tagBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: fg),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              text.toUpperCase(),
              style: AppText.display(size: fontSize, color: fg, height: 1.1),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
