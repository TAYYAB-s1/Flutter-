import 'package:hive/hive.dart';

/// One logged search (voice or typed) that returned zero product
/// matches. typeId 2 — Product uses 0, PriceHistoryEntry uses 1.
class FailedSearchEntry {
  String id;
  String query;
  DateTime searchedAt;

  FailedSearchEntry({
    required this.id,
    required this.query,
    required this.searchedAt,
  });
}

class FailedSearchEntryAdapter extends TypeAdapter<FailedSearchEntry> {
  @override
  final int typeId = 2;

  @override
  FailedSearchEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FailedSearchEntry(
      id: fields[0] as String,
      query: fields[1] as String,
      searchedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FailedSearchEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.query)
      ..writeByte(2)
      ..write(obj.searchedAt);
  }
}