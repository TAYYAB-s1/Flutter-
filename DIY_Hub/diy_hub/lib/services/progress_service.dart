// lib/services/progress_service.dart
// Single place for all local persistence: onboarding state, theme mode,
// XP/rank tracking, per-skill progress, and favorites. Backed by
// shared_preferences so everything survives app restarts.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress_model.dart';
import '../models/skill_model.dart';
import '../models/user_stats_model.dart';

class ProgressService {
  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyThemeMode = 'theme_mode';
  static const _keyUserStats = 'user_stats';
  static const _keyAllProgress = 'all_progress';

  // ── Onboarding ────────────────────────────────────────────────────

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  /// Call once when the user picks their Hero Tier on the onboarding screen.
  Future<void> completeOnboarding(HeroTier tier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, true);
    await saveUserStats(UserStatsModel.initial(heroTier: tier));
  }

  // ── Theme ─────────────────────────────────────────────────────────

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyThemeMode);
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  // ── User stats (XP / Hero Tier / Rank) ──────────────────────────

  Future<UserStatsModel> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUserStats);
    if (raw == null) return UserStatsModel.initial();
    return UserStatsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveUserStats(UserStatsModel stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserStats, jsonEncode(stats.toJson()));
  }

  Future<void> setHeroTier(HeroTier tier) async {
    final stats = await getUserStats();
    await saveUserStats(stats.copyWith(heroTier: tier));
  }

  /// Adds XP to the user's total and returns true if this pushed them into
  /// a new rank (used to trigger a "Rank Up!" celebration in the UI).
  Future<bool> addXp(int amount) async {
    final before = await getUserStats();
    final after = before.copyWith(totalXp: before.totalXp + amount);
    await saveUserStats(after);
    return after.currentRank != before.currentRank;
  }

  // ── Per-skill progress ───────────────────────────────────────────

  Future<Map<String, ProgressModel>> getAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAllProgress);
    if (raw == null) return {};
    final Map<String, dynamic> decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, ProgressModel.fromJson(value as Map<String, dynamic>)),
    );
  }

  Future<ProgressModel> getProgress(String skillId) async {
    final all = await getAllProgress();
    return all[skillId] ?? ProgressModel.empty(skillId);
  }

  Future<void> _saveAllProgress(Map<String, ProgressModel> all) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = all.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_keyAllProgress, jsonEncode(encoded));
  }

  Future<void> toggleFavorite(String skillId) async {
    final all = await getAllProgress();
    final current = all[skillId] ?? ProgressModel.empty(skillId);
    all[skillId] = current.copyWith(isFavorite: !current.isFavorite);
    await _saveAllProgress(all);
  }

  /// Marks a lesson complete for a skill. If this was the final lesson,
  /// the skill is marked fully completed and its XP reward is granted once.
  /// Returns true if completing this lesson caused a rank-up.
  Future<bool> markLessonComplete({
    required String skillId,
    required String lessonId,
    required int totalLessons,
    required int xpReward,
  }) async {
    final all = await getAllProgress();
    final current = all[skillId] ?? ProgressModel.empty(skillId);

    if (current.completedLessonIds.contains(lessonId)) {
      // Already completed — nothing new to award.
      return false;
    }

    final updatedLessonIds = {...current.completedLessonIds, lessonId};
    final justFinishedSkill =
        updatedLessonIds.length >= totalLessons && current.completedAt == null;

    final updated = current.copyWith(
      completedLessonIds: updatedLessonIds,
      completedAt: justFinishedSkill ? DateTime.now() : current.completedAt,
    );

    all[skillId] = updated;
    await _saveAllProgress(all);

    if (justFinishedSkill) {
      return addXp(xpReward);
    }
    return false;
  }
}