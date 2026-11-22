// lib/screens/lesson_screen.dart
// MISSION PLAYER: one episode, one step at a time, on a black stage.
//   - Top bar in the lab's color: close button + "EPISODE 2 OF 4 · TITLE"
//   - "STEP 2 OF 3_" label, a blocky step bar, and the instruction text
//   - Bottom bar: PREVIOUS and NEXT (COMPLETE EPISODE on the last step)
//
// Logic is unchanged: XP is awarded only when the whole mission is finished
// (inside ProgressService.markLessonComplete). Finishing a non-final episode
// moves straight to the next episode; finishing the final one shows the
// Mission Complete dialog and then returns to Mission Detail.
// Black here is a fixed design accent, not a dark theme.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../models/skill_model.dart';
import '../services/progress_service.dart';
import '../widgets/brutal_button.dart';
import '../widgets/mission_complete_dialog.dart';
import '../widgets/segmented_step_bar.dart';
import '../widgets/stage_grid.dart';

class LessonScreen extends StatefulWidget {
  final SkillModel skill;
  final int lessonIndex;

  const LessonScreen({super.key, required this.skill, required this.lessonIndex});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _progressService = ProgressService();
  int _stepIndex = 0;
  bool _submitting = false;

  // Blinking "_" after the step label.
  bool _cursorOn = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 550), (_) {
      if (mounted) setState(() => _cursorOn = !_cursorOn);
    });
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    super.dispose();
  }

  Future<void> _completeEpisode() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final skill = widget.skill;
    final lesson = skill.lessons[widget.lessonIndex];
    final isFinalEpisode = widget.lessonIndex == skill.lessons.length - 1;

    // A mission that was already finished earns no XP again (replay).
    final before = await _progressService.getProgress(skill.id);
    final alreadyCompleted = before.isCompleted;

    final rankedUp = await _progressService.markLessonComplete(
      skillId: skill.id,
      lessonId: lesson.id,
      totalLessons: skill.lessons.length,
      xpReward: skill.xpReward,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (!isFinalEpisode) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonScreen(skill: skill, lessonIndex: widget.lessonIndex + 1),
        ),
      );
      return;
    }

    final xpEarned = alreadyCompleted ? 0 : skill.xpReward;
    DifficultyRank? previousRank;
    DifficultyRank? newRank;
    if (rankedUp) {
      final stats = await _progressService.getUserStats();
      newRank = stats.currentRank;
      previousRank = stats.copyWith(totalXp: stats.totalXp - xpEarned).currentRank;
    }

    if (!mounted) return;
    await showMissionCompleteDialog(
      context,
      skill: skill,
      xpEarned: xpEarned,
      previousRank: previousRank,
      newRank: newRank,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true); // back to Mission Detail, signal a refresh
  }

  @override
  Widget build(BuildContext context) {
    final skill = widget.skill;
    final lesson = skill.lessons[widget.lessonIndex];
    final steps = lesson.steps.isEmpty ? const ['Complete this episode.'] : lesson.steps;
    final accent = skill.accentColor;
    final isFirstStep = _stepIndex == 0;
    final isLastStep = _stepIndex == steps.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: Column(
          children: [
            _buildTopBar(skill, lesson.title, accent),
            Expanded(
              child: StageGrid(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: 'STEP ${_stepIndex + 1} OF ${steps.length}',
                          children: [
                            TextSpan(
                              text: '_',
                              style: TextStyle(
                                color: _cursorOn ? accent : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                        style: AppText.tag(size: 14, color: accent),
                      ),
                      const SizedBox(height: 12),
                      SegmentedStepBar(
                        total: steps.length,
                        current: _stepIndex + 1,
                        currentColor: accent,
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          border: Border.all(color: AppColors.white, width: AppTheme.borderWidth),
                          boxShadow: [
                            BoxShadow(color: accent, offset: const Offset(6, 6), blurRadius: 0),
                          ],
                        ),
                        child: Text(
                          steps[_stepIndex],
                          style: AppText.body(
                            size: 22,
                            color: AppColors.white,
                            weight: FontWeight.w600,
                          ).copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(accent, isFirstStep, isLastStep),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(SkillModel skill, String episodeTitle, Color accent) {
    return Container(
      color: accent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 16, 12),
          child: Row(
            children: [
              Tooltip(
                message: 'Close',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.fromBorderSide(AppTheme.tagBorder),
                    ),
                    child: const Icon(Icons.close, size: 26, color: AppColors.ink),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'EPISODE ${widget.lessonIndex + 1} OF ${skill.lessons.length} · ${episodeTitle.toUpperCase()}',
                  style: AppText.display(size: 15, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(Color accent, bool isFirstStep, bool isLastStep) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.ink,
        border: Border(top: BorderSide(color: AppColors.white, width: 2)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: BrutalButton(
                label: 'Back',
                icon: Icons.arrow_back,
                iconAfterLabel: false,
                style: BrutalButtonStyle.secondary,
                shadowColor: accent,
                fontSize: 14,
                onPressed: (isFirstStep || _submitting)
                    ? null
                    : () => setState(() => _stepIndex--),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: BrutalButton(
                label: isLastStep ? 'Complete episode' : 'Next',
                icon: isLastStep ? Icons.check : Icons.arrow_forward,
                shadowColor: accent,
                fontSize: 14,
                loading: _submitting,
                onPressed: _submitting
                    ? null
                    : (isLastStep ? _completeEpisode : () => setState(() => _stepIndex++)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
