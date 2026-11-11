// lib/widgets/brutal_card.dart
// The base surface of the whole app: a flat box with a thick ink border and
// a hard offset shadow (zero blur). When [onTap] is set it "presses in":
// it shifts 2px toward the shadow while the shadow shrinks.
//
// NOTE: the shadow is drawn outside the box (right and down), so leave a
// few pixels of padding around cards in lists and grids.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

class BrutalCard extends StatefulWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double borderWidth;
  final double shadowOffset;
  final Color shadowColor;
  final Clip clipBehavior;

  const BrutalCard({
    super.key,
    required this.child,
    this.color = AppColors.white,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.borderWidth = AppTheme.borderWidth,
    this.shadowOffset = AppTheme.shadowOffset,
    this.shadowColor = AppColors.ink,
    this.clipBehavior = Clip.none,
  });

  @override
  State<BrutalCard> createState() => _BrutalCardState();
}

class _BrutalCardState extends State<BrutalCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final maxShift = widget.shadowOffset < 2 ? widget.shadowOffset : 2.0;
    final shift = (interactive && _pressed) ? maxShift : 0.0;
    final shadow = widget.shadowOffset - shift;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(shift, shift, 0),
      padding: widget.padding,
      clipBehavior: widget.clipBehavior,
      decoration: BoxDecoration(
        color: widget.color,
        border: Border.all(color: AppColors.ink, width: widget.borderWidth),
        boxShadow: shadow > 0
            ? [
                BoxShadow(
                    color: widget.shadowColor,
                    offset: Offset(shadow, shadow),
                    blurRadius: 0)
              ]
            : const [],
      ),
      child: widget.child,
    );

    if (!interactive) return card;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: card,
    );
  }
}
