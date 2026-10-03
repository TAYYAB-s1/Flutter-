import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../../../models/price_history_entry.dart';

class PriceHistoryRepository {
  static const String boxName = 'price_history';

  Box<PriceHistoryEntry> get _box => Hive.box<PriceHistoryEntry>(boxName);

  static Future<void> init() async {
    Hive.registerAdapter(PriceHistoryEntryAdapter());
    await Hive.openBox<PriceHistoryEntry>(boxName);
  }

  /// Logs one price change. Call this BEFORE saving the updated
  /// product, passing the product's price as it was before this edit
  /// and the new price it's being changed to.
  Future<void> logChange({
    required String productId,
    required double oldPrice,
    required double newPrice,
    bool isInitial = false,
  }) async {
    final entry = PriceHistoryEntry(
      id: const Uuid().v4(),
      productId: productId,
      oldPrice: oldPrice,
      newPrice: newPrice,
      changedAt: DateTime.now(),
      isInitial: isInitial,
    );
    await _box.put(entry.id, entry);
  }

  /// Returns this product's history, most recent change first.
  List<PriceHistoryEntry> getHistoryForProduct(String productId) {
    final entries =
        _box.values.where((e) => e.productId == productId).toList();
    entries.sort((a, b) => b.changedAt.compareTo(a.changedAt));
    return entries;
  }

  /// Call when a product is permanently deleted, so its history
  /// doesn't linger forever as orphaned data.
  Future<void> deleteHistoryForProduct(String productId) async {
    final keysToDelete = _box.values
        .where((e) => e.productId == productId)
        .map((e) => e.id)
        .toList();
    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }
}