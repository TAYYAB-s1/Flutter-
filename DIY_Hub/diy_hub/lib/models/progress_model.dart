// lib/models/progress_model.dart
// Tracks a user's progress on a single skill (completed lessons, favorite state).
// Serialized to JSON so it can be persisted via shared_preferences.

class ProgressModel {
  final String skillId;
  final Set<String> completedLessonIds;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isFavorite;

  const ProgressModel({
    required this.skillId,
    required this.completedLessonIds,
    required this.startedAt,
    this.completedAt,
    this.isFavorite = false,
  });

  /// A fresh, empty progress record for a skill the user hasn't started yet.
  factory ProgressModel.empty(String skillId) {
    return ProgressModel(
      skillId: skillId,
      completedLessonIds: <String>{},
      startedAt: DateTime.now(),
      isFavorite: false,
    );
  }

  bool get isCompleted => completedAt != null;

  double progressPercent(int totalLessons) {
    if (totalLessons == 0) return 0;
    return (completedLessonIds.length / totalLessons).clamp(0, 1).toDouble();
  }

  ProgressModel copyWith({
    Set<String>? completedLessonIds,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isFavorite,
    bool clearCompletedAt = false,
  }) {
    return ProgressModel(
      skillId: skillId,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      startedAt: startedAt ?? this.startedAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skillId': skillId,
      'completedLessonIds': completedLessonIds.toList(),
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      skillId: json['skillId'] as String,
      completedLessonIds: Set<String>.from(json['completedLessonIds'] as List? ?? []),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}