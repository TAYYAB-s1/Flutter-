// lib/models/user_stats_model.dart
// Tracks the user's overall XP total and Hero Tier. Current rank is
// computed from XP thresholds rather than stored directly.

import 'skill_model.dart';

class UserStatsModel {
  final int totalXp;
  final HeroTier heroTier;

  const UserStatsModel({
    required this.totalXp,
    required this.heroTier,
  });

  /// Default stats for a brand-new user, used before onboarding sets a tier.
  factory UserStatsModel.initial({HeroTier heroTier = HeroTier.teens}) {
    return UserStatsModel(totalXp: 0, heroTier: heroTier);
  }

  // XP thresholds for each rank — tweak here if game balance needs adjusting.
  static const int cadetThreshold = 500;
  static const int masterThreshold = 1500;

  DifficultyRank get currentRank {
    if (totalXp >= masterThreshold) return DifficultyRank.master;
    if (totalXp >= cadetThreshold) return DifficultyRank.cadet;
    return DifficultyRank.novice;
  }

  /// XP needed to reach the next rank, or null if already at max rank.
  int? get xpToNextRank {
    switch (currentRank) {
      case DifficultyRank.novice:
        return cadetThreshold - totalXp;
      case DifficultyRank.cadet:
        return masterThreshold - totalXp;
      case DifficultyRank.master:
        return null;
    }
  }

  UserStatsModel copyWith({int? totalXp, HeroTier? heroTier}) {
    return UserStatsModel(
      totalXp: totalXp ?? this.totalXp,
      heroTier: heroTier ?? this.heroTier,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalXp': totalXp,
      'heroTier': heroTier.name,
    };
  }

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalXp: json['totalXp'] as int? ?? 0,
      heroTier: HeroTier.values.firstWhere(
        (t) => t.name == json['heroTier'],
        orElse: () => HeroTier.teens,
      ),
    );
  }
}