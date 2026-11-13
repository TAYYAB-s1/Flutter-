// lib/widgets/key_value_row.dart
// "Category ........ Robotics": label left, value right, dotted leader
// between. Used in the Mission Specs panel. [highlight] puts the value on a
// yellow block (used for the XP reward).

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

class KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final Color? valueColor;

  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final valueText = Text(
      value,
      style: AppText.tag(color: valueColor ?? AppColors.ink),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label.toUpperCase(),
              style:
                  AppText.tag(color: AppColors.muted, weight: FontWeight.w400)),
          const SizedBox(width: 6),
          const Expanded(
            child: SizedBox(
              height: 4,
              child: CustomPaint(painter: _DottedLeaderPainter()),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: highlight
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: AppColors.actionYellow,
                    child: valueText,
                  )
                : valueText,
          ),
        ],
      ),
    );
  }
}

class _DottedLeaderPainter extends CustomPainter {
  const _DottedLeaderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.muted;
    for (double x = 1; x < size.width; x += 5) {
      canvas.drawCircle(Offset(x, size.height / 2), 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLeaderPainter oldDelegate) => false;
}
