// lib/widgets/mission_cover.dart
// The generated cover art for a mission. We have no photos, so a cover is:
// flat category color + halftone dots + one chunky icon in a white square.
// Optional corner overlays hold the rank badge, XP tag, etc.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../models/skill_model.dart';
import 'halftone_background.dart';

class MissionCover extends StatelessWidget {
  final SkillModel skill;
  final double aspectRatio;
  final double iconBoxSize;
  final Widget? topLeft;
  final Widget? topRight;
  final Widget? bottomLeft;
  final Widget? bottomRight;

  const MissionCover({
    super.key,
    required this.skill,
    this.aspectRatio = 1.6,
    this.iconBoxSize = 64,
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        color: skill.accentColor,
        child: HalftoneBackground(
          dotColor: AppColors.halftoneDot,
          dotSpacing: 8,
          dotRadius: 1.2,
          child: SizedBox.expand(
            child: Stack(
              children: [
                Center(
                    child: CoverIconBox(icon: skill.icon, size: iconBoxSize)),
                if (topLeft != null)
                  Positioned(top: 8, left: 8, child: topLeft!),
                if (topRight != null)
                  Positioned(top: 8, right: 8, child: topRight!),
                if (bottomLeft != null)
                  Positioned(bottom: 8, left: 8, child: bottomLeft!),
                if (bottomRight != null)
                  Positioned(bottom: 8, right: 8, child: bottomRight!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// White bordered square holding a big ink icon. Also reused by category
/// tiles, trophy badges and the stage panel.
class CoverIconBox extends StatelessWidget {
  final IconData icon;
  final double size;

  const CoverIconBox({super.key, required this.icon, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.fromBorderSide(AppTheme.border),
      ),
      child: Icon(icon, size: size * 0.55, color: AppColors.ink),
    );
  }
}
