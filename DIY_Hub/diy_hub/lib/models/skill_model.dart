// lib/models/skill_model.dart
// Internal name stays "Skill" — the UI displays these as "Missions".

import 'package:flutter/material.dart';
import 'lesson_model.dart';

/// Difficulty rank shown as a badge (e.g. "★ RANK: NOVICE") on mission cards.
enum DifficultyRank { novice, cadet, master }

extension DifficultyRankX on DifficultyRank {
  String get label {
    switch (this) {
      case DifficultyRank.novice:
        return 'Novice';
      case DifficultyRank.cadet:
        return 'Cadet';
      case DifficultyRank.master:
        return 'Master';
    }
  }

  /// Number of stars shown next to the rank badge, matching the mockup.
  int get starCount {
    switch (this) {
      case DifficultyRank.novice:
        return 1;
      case DifficultyRank.cadet:
        return 2;
      case DifficultyRank.master:
        return 3;
    }
  }
}

/// Age-based "Hero Tier" selected once during onboarding.
enum HeroTier { kids, teens, adult }

extension HeroTierX on HeroTier {
  String get title {
    switch (this) {
      case HeroTier.kids:
        return 'Rookie Builders';
      case HeroTier.teens:
        return 'Maker Cadets';
      case HeroTier.adult:
        return 'Master Artisans';
    }
  }

  String get ageRangeLabel {
    switch (this) {
      case HeroTier.kids:
        return 'Ages 5-12';
      case HeroTier.teens:
        return 'Ages 13-17';
      case HeroTier.adult:
        return 'Ages 18+';
    }
  }
}

class SkillModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final IconData icon;
  final Color accentColor;
  final DifficultyRank difficultyRank;
  final int estimatedMinutes;
  final int stepCount;
  final int xpReward;
  final List<String> materialsList;
  final HeroTier minHeroTier;
  final List<LessonModel> lessons;

  const SkillModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.difficultyRank,
    required this.estimatedMinutes,
    required this.stepCount,
    required this.xpReward,
    required this.materialsList,
    required this.minHeroTier,
    required this.lessons,
  });
}