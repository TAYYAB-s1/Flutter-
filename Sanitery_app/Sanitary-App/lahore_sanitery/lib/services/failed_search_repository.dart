import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/failed_search_entry.dart';

class FailedSearchRepository {
  static const String boxName = 'failed_searches';

  Box<FailedSearchEntry> get _box => Hive.box<FailedSearchEntry>(boxName);

  static Future<void> init() async {
    Hive.registerAdapter(FailedSearchEntryAdapter());
    await Hive.openBox<FailedSearchEntry>(boxName);
  }

  Future<void> logFailedSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final entry = FailedSearchEntry(
      id: const Uuid().v4(),
      query: trimmed,
      searchedAt: DateTime.now(),
    );
    await _box.put(entry.id, entry);
  }

  List<FailedSearchEntry> getAll() {
    final entries = _box.values.toList();
    entries.sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
    return entries;
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}