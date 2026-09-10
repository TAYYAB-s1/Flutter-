// lib/services/storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversion_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StorageService — singleton that reads/writes conversion history
// and app settings to SharedPreferences
// ─────────────────────────────────────────────────────────────────────────────

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  // SharedPreferences keys
  static const _kHistory      = 'conversion_history';
  static const _kThemeMode    = 'theme_mode';    // 'dark' | 'light'
  static const _kSeedColor    = 'seed_color';    // int (Color.value)
  static const _kAutoDelete   = 'auto_delete';   // bool
  static const _kDownloadPath = 'download_path'; // String

  // ═══════════════════════════════════════════════════════════════════════════
  // HISTORY — Save, load, delete conversions
  // ═══════════════════════════════════════════════════════════════════════════

  /// Load all conversion history from storage.
  /// Returns newest-first (index 0 = most recent).
  Future<List<ConversionModel>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw   = prefs.getStringList(_kHistory) ?? [];

      final list = raw
          .map((json) {
            try {
              return ConversionModel.fromJson(json);
            } catch (_) {
              return null; // Skip corrupted entries
            }
          })
          .whereType<ConversionModel>()
          .toList();

      // Newest first
      list.sort((a, b) => b.convertedAt.compareTo(a.convertedAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Add a new conversion to the top of history.
  /// Keeps a maximum of 100 entries to avoid bloating storage.
  Future<void> saveConversion(ConversionModel conversion) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final current = prefs.getStringList(_kHistory) ?? [];

      // Insert at front (newest first)
      current.insert(0, conversion.toJson());

      // Trim to 100 entries
      if (current.length > 100) {
        current.removeRange(100, current.length);
      }

      await prefs.setStringList(_kHistory, current);
    } catch (_) {
      // Storage write failure — silently ignore
    }
  }

  /// Delete a single conversion by its ID.
  Future<void> deleteConversion(String id) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final current = prefs.getStringList(_kHistory) ?? [];

      final updated = current.where((json) {
        try {
          final map = jsonDecode(json) as Map<String, dynamic>;
          return map['id'] != id;
        } catch (_) {
          return true; // Keep entries we can't parse
        }
      }).toList();

      await prefs.setStringList(_kHistory, updated);
    } catch (_) {}
  }

  /// Delete ALL conversion history.
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kHistory);
    } catch (_) {}
  }

  /// Returns the number of saved conversions.
  Future<int> historyCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_kHistory) ?? []).length;
    } catch (_) {
      return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SETTINGS — Theme, color, preferences
  // ═══════════════════════════════════════════════════════════════════════════

  /// Save theme mode: 'dark' | 'light'
  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, mode);
  }

  /// Load saved theme mode. Returns 'dark' by default.
  Future<String> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kThemeMode) ?? 'dark';
  }

  /// Save the selected seed color as an integer.
  Future<void> saveSeedColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSeedColor, colorValue);
  }

  /// Load saved seed color. Returns null if not set.
  Future<int?> loadSeedColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kSeedColor);
  }

  /// Save auto-delete preference.
  Future<void> saveAutoDelete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoDelete, value);
  }

  /// Load auto-delete setting. Returns true by default.
  Future<bool> loadAutoDelete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kAutoDelete) ?? true;
  }

  /// Save custom download path.
  Future<void> saveDownloadPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDownloadPath, path);
  }

  /// Load download path. Returns null if default.
  Future<String?> loadDownloadPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kDownloadPath);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CACHE — Estimate storage used by saved history JSON
  // ═══════════════════════════════════════════════════════════════════════════

  /// Returns approximate cache size in bytes from stored history JSON.
  Future<int> estimateCacheSizeBytes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw   = prefs.getStringList(_kHistory) ?? [];
      return raw.fold<int>(0, (sum, json) => sum + json.length);
    } catch (_) {
      return 0;
    }
  }

  /// Human-readable cache size string e.g. "12 KB"
  Future<String> formattedCacheSize() async {
    final bytes = await estimateCacheSizeBytes();
    if (bytes < 1024)        return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Clear all app preferences (settings + history).
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
  }
}