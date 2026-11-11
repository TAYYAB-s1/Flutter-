// lib/widgets/brutal_button.dart
// Square button with a thick ink border and a hard shadow.
//   primary   = action yellow (the only place yellow is used for actions)
//   secondary = white
//   danger    = red
//   dark      = ink black
// Pass onPressed: null to disable. Set loading: true to show a spinner.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

enum BrutalButtonStyle { primary, secondary, danger, dark }

class BrutalButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool iconAfterLabel;
  final BrutalButtonStyle style;
  final bool expand;
  final bool loading;
  final double height;
  final double fontSize;
  final Color shadowColor;

  const BrutalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconAfterLabel = true,
    this.style = BrutalButtonStyle.primary,
    this.expand = true,
    this.loading = false,
    this.height = 52,
    this.fontSize = 15,
    this.shadowColor = AppColors.ink,
  });

  @override
  State<BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<BrutalButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  Color get _background {
    switch (widget.style) {
      case BrutalButtonStyle.primary:
        return AppColors.actionYellow;
      case BrutalButtonStyle.secondary:
        return AppColors.white;
      case BrutalButtonStyle.danger:
        return AppColors.danger;
      case BrutalButtonStyle.dark:
        return AppColors.ink;
    }
  }

  Color get _foreground {
    switch (widget.style) {
      case BrutalButtonStyle.primary:
      case BrutalButtonStyle.secondary:
        return AppColors.ink;
      case BrutalButtonStyle.danger:
      case BrutalButtonStyle.dark:
        return AppColors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null && !widget.loading;
    final tappable = widget.onPressed != null && !widget.loading;

    final bg = disabled ? AppColors.locked : _background;
    final fg = disabled ? AppColors.muted : _foreground;

    final shift = (tappable && _pressed) ? 2.0 : 0.0;
    final shadow = disabled ? 0.0 : AppTheme.shadowOffset - shift;

    final textStyle =
        AppText.display(size: widget.fontSize, color: fg, height: 1.1);
    final iconWidget = widget.icon == null
        ? null
        : Icon(widget.icon, size: widget.fontSize + 5, color: fg);

    final Widget content;
    if (widget.loading) {
      content = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 3, color: fg),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconWidget != null && !widget.iconAfterLabel) ...[
            iconWidget,
            const SizedBox(width: 8)
          ],
          Flexible(
            child: Text(
              widget.label.toUpperCase(),
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (iconWidget != null && widget.iconAfterLabel) ...[
            const SizedBox(width: 8),
            iconWidget
          ],
        ],
      );
    }

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(shift, shift, 0),
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: AppColors.ink, width: AppTheme.borderWidth),
        boxShadow: shadow > 0
            ? [
                BoxShadow(
                    color: widget.shadowColor,
                    offset: Offset(shadow, shadow),
                    blurRadius: 0)
              ]
            : const [],
      ),
      child: content,
    );

    final interactive = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: tappable ? widget.onPressed : null,
      onTapDown: tappable ? (_) => _setPressed(true) : null,
      onTapUp: tappable ? (_) => _setPressed(false) : null,
      onTapCancel: tappable ? () => _setPressed(false) : null,
      child: button,
    );

    final semantic = Semantics(
      button: true,
      enabled: tappable,
      label: widget.label,
      excludeSemantics: true,
      child: interactive,
    );

    // Leave room on the right/bottom for the hard shadow.
    final padded = Padding(
      padding: const EdgeInsets.only(
          right: AppTheme.shadowOffset, bottom: AppTheme.shadowOffset),
      child: semantic,
    );

    return widget.expand
        ? SizedBox(width: double.infinity, child: padded)
        : padded;
  }
}
