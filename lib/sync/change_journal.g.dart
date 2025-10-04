// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_journal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChangeJournalEntryAdapter extends TypeAdapter<ChangeJournalEntry> {
  @override
  final int typeId = 10;

  @override
  ChangeJournalEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChangeJournalEntry(
      id: fields[0] as String,
      entityType: fields[1] as String,
      entityId: fields[2] as String,
      operation: fields[3] as ChangeOperation,
      timestamp: fields[4] as DateTime,
      attempt: fields[5] as int,
      metadata: (fields[6] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChangeJournalEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.entityType)
      ..writeByte(2)
      ..write(obj.entityId)
      ..writeByte(3)
      ..write(obj.operation)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.attempt)
      ..writeByte(6)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeJournalEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChangeOperationAdapter extends TypeAdapter<ChangeOperation> {
  @override
  final int typeId = 11;

  @override
  ChangeOperation read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChangeOperation.create;
      case 1:
        return ChangeOperation.update;
      case 2:
        return ChangeOperation.delete;
      default:
        return ChangeOperation.create;
    }
  }

  @override
  void write(BinaryWriter writer, ChangeOperation obj) {
    switch (obj) {
      case ChangeOperation.create:
        writer.writeByte(0);
        break;
      case ChangeOperation.update:
        writer.writeByte(1);
        break;
      case ChangeOperation.delete:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
