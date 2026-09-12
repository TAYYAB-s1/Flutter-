// lib/models/lesson_model.dart
// Internal name stays "Lesson" — the UI displays these as "Episodes" / "Phases".

class LessonModel {
  final String id;
  final String title;
  final List<String> steps;
  final int order;

  const LessonModel({
    required this.id,
    required this.title,
    required this.steps,
    required this.order,
  });
}