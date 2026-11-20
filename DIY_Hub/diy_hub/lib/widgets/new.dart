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
