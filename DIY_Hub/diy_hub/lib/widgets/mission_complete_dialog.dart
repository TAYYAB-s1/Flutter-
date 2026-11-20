// lib/widgets/mission_complete_dialog.dart
// "MISSION COMPLETE!" dialog shown after the final episode of a mission.
// Shows the XP earned and, when the XP crossed a rank threshold, a
// "RANK UP! NOVICE -> CADET" banner. On a replay (the mission was already
// finished) no XP is added, so it says so instead of showing "+XP".

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../models/skill_model.dart';
import 'brutal_button.dart';
import 'brutal_card.dart';
import 'halftone_background.dart';
import 'sticker_label.dart';

/// Opens the dialog and completes when the user taps CONTINUE.
Future<void> showMissionCompleteDialog(
  BuildContext context, {
  required SkillModel skill,
  required int xpEarned,
  DifficultyRank? previousRank,
  DifficultyRank? newRank,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0x99000000),
    builder: (_) => _MissionCompleteDialog(
      skill: skill,
      xpEarned: xpEarned,
      previousRank: previousRank,
      newRank: newRank,
    ),
  );
}

class _MissionCompleteDialog extends StatelessWidget {
  final SkillModel skill;
  final int xpEarned;
  final DifficultyRank? previousRank;
  final DifficultyRank? newRank;

  const _MissionCompleteDialog({
    required this.skill,
    required this.xpEarned,
    required this.previousRank,
    required this.newRank,
  });

  bool get _rankedUp =>
      previousRank != null && newRank != null && previousRank != newRank;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: BrutalCard(
        shadowOffset: 8,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: StickerLabel(
                text: 'Mission complete!',
                color: AppColors.success,
                icon: Icons.check,
              ),
            ),
            const SizedBox(height: 16),
            Text(skill.title.toUpperCase(), style: AppText.display(size: 22)),
            const SizedBox(height: 16),
            if (xpEarned > 0)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, size: 40, color: AppColors.ink),
                    Text('+$xpEarned XP', style: AppText.display(size: 44)),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  border: Border.fromBorderSide(AppTheme.tagBorder),
                ),
                child: Text(
                  'ALREADY EARNED. NO NEW XP THIS TIME.',
                  style: AppText.tag(size: 12, color: AppColors.muted),
                ),
              ),
            if (_rankedUp) ...[
              const SizedBox(height: 18),
              BrutalCard(
                color: AppColors.categoryCookingLab,
                shadowOffset: 4,
                clipBehavior: Clip.hardEdge,
                child: HalftoneBackground(
                  dotColor: AppColors.halftoneDot,
                  dotSpacing: 8,
                  dotRadius: 1.2,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Text('RANK UP!', style: AppText.display(size: 22)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              previousRank!.label.toUpperCase(),
                              style: AppText.display(size: 16),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.arrow_forward,
                                  size: 22, color: AppColors.ink),
                            ),
                            Text(
                              newRank!.label.toUpperCase(),
                              style: AppText.display(size: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            BrutalButton(
              label: 'Continue',
              icon: Icons.arrow_forward,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
