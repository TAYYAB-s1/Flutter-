// lib/screens/lesson_screen.dart
// A single Mission Episode — walks the user through its steps one at a
// time. Completing the final step of the final episode triggers XP award
// and a "Mission Complete!" celebration (with a Rank Up variant).

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/skill_model.dart';
import '../services/progress_service.dart';
import '../widgets/comic_burst_badge.dart';
import '../widgets/halftone_background.dart';

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

  @override
  Widget build(BuildContext context) {
    final skill = widget.skill;
    final lesson = skill.lessons[widget.lessonIndex];
    final steps = lesson.steps;
    final isLastStep = _stepIndex == steps.length - 1;
    final isFirstStep = _stepIndex == 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('EPISODE ${widget.lessonIndex + 1} OF ${skill.lessons.length}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: HalftoneBackground(
                    dotColor: Colors.black.withOpacity(0.08),
                    child: Container(
                      color: skill.accentColor.withOpacity(0.4),
                      child: Center(child: Icon(skill.icon, size: 52, color: Colors.black87)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'STEP ${_stepIndex + 1} OF ${steps.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: skill.accentColor,
                    ),
              ),
              const SizedBox(height: 6),
              Text(lesson.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
                        width: 2.5,
                      ),
                    ),
                    child: Text(steps[_stepIndex], style: Theme.of(context).textTheme.bodyLarge),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isFirstStep ? null : () => setState(() => _stepIndex--),
                      child: const Text('← PREVIOUS'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: skill.accentColor),
                      onPressed: _submitting
                          ? null
                          : () {
                              if (isLastStep) {
                                _completeEpisode();
                              } else {
                                setState(() => _stepIndex++);
                              }
                            },
                      child: _submitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(isLastStep ? 'COMPLETE EPISODE ✓' : 'NEXT →'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeEpisode() async {
    setState(() => _submitting = true);

    final skill = widget.skill;
    final lesson = skill.lessons[widget.lessonIndex];

    final rankedUp = await _progressService.markLessonComplete(
      skillId: skill.id,
      lessonId: lesson.id,
      totalLessons: skill.lessons.length,
      xpReward: skill.xpReward,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    final isFinalEpisode = widget.lessonIndex == skill.lessons.length - 1;

    if (isFinalEpisode) {
      await _showMissionCompleteDialog(rankedUp);
      if (!mounted) return;
      Navigator.of(context).pop(true); // back to Skill Detail, signal a refresh
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonScreen(skill: skill, lessonIndex: widget.lessonIndex + 1),
        ),
      );
    }
  }

  Future<void> _showMissionCompleteDialog(bool rankedUp) async {
    final skill = widget.skill;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ComicBurstBadge(
                text: rankedUp ? 'RANK\nUP!' : 'DONE!',
                size: 90,
                color: rankedUp ? AppColors.comicRed : AppColors.success,
              ),
              const SizedBox(height: 16),
              Text(
                'MISSION COMPLETE!',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You earned +${skill.xpReward} XP for "${skill.title}"',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (rankedUp) ...[
                const SizedBox(height: 8),
                Text(
                  '🎉 You leveled up to a new Rank!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.comicRed,
                      ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('AWESOME!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}