import 'package:hive/hive.dart';

/// One logged price change for a product. typeId 1 — Product already
/// uses typeId 0, every new Hive model needs its own unique typeId.
class PriceHistoryEntry {
  String id;
  String productId;
  double oldPrice;
  double newPrice;
  DateTime changedAt;

  /// True for the very first entry logged when a product is created
  /// (oldPrice == newPrice in that case — there's no "previous"
  /// price yet). Lets the UI show "Added at Rs. X" instead of
  /// "Changed from Rs. X to Rs. X", which would look like a bug.
  bool isInitial;

  PriceHistoryEntry({
    required this.id,
    required this.productId,
    required this.oldPrice,
    required this.newPrice,
    required this.changedAt,
    this.isInitial = false,
  });
}

class PriceHistoryEntryAdapter extends TypeAdapter<PriceHistoryEntry> {
  @override
  final int typeId = 1;

  @override
  PriceHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceHistoryEntry(
      id: fields[0] as String,
      productId: fields[1] as String,
      oldPrice: fields[2] as double,
      newPrice: fields[3] as double,
      changedAt: fields[4] as DateTime,
      isInitial: fields.containsKey(5) ? fields[5] as bool : false,
    );
  }

  @override
  void write(BinaryWriter writer, PriceHistoryEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.oldPrice)
      ..writeByte(3)
      ..write(obj.newPrice)
      ..writeByte(4)
      ..write(obj.changedAt)
      ..writeByte(5)
      ..write(obj.isInitial);
  }
}