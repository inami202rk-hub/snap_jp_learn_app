// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'srs_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SrsCardAdapter extends TypeAdapter<SrsCard> {
  @override
  final int typeId = 1;

  @override
  SrsCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SrsCard(
      id: fields[0] as String,
      term: fields[1] as String,
      reading: fields[2] as String,
      meaning: fields[3] as String,
      sourcePostId: fields[4] as String,
      sourceSnippet: fields[5] as String,
      createdAt: fields[6] as DateTime,
      interval: fields[7] as int,
      easeFactor: fields[8] as double,
      repetition: fields[9] as int,
      due: fields[10] as DateTime,
      syncId: fields[11] as String?,
      updatedAt: fields[12] as DateTime?,
      dirty: fields[13] as bool,
      deleted: fields[14] as bool,
      version: fields[15] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SrsCard obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.term)
      ..writeByte(2)
      ..write(obj.reading)
      ..writeByte(3)
      ..write(obj.meaning)
      ..writeByte(4)
      ..write(obj.sourcePostId)
      ..writeByte(5)
      ..write(obj.sourceSnippet)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.interval)
      ..writeByte(8)
      ..write(obj.easeFactor)
      ..writeByte(9)
      ..write(obj.repetition)
      ..writeByte(10)
      ..write(obj.due)
      ..writeByte(11)
      ..write(obj.syncId)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.dirty)
      ..writeByte(14)
      ..write(obj.deleted)
      ..writeByte(15)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SrsCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
