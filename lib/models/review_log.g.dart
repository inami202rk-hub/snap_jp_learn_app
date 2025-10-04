// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReviewLogAdapter extends TypeAdapter<ReviewLog> {
  @override
  final int typeId = 2;

  @override
  ReviewLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReviewLog(
      id: fields[0] as String,
      cardId: fields[1] as String,
      reviewedAt: fields[2] as DateTime,
      rating: fields[3] as String,
      syncId: fields[4] as String?,
      updatedAt: fields[5] as DateTime?,
      dirty: fields[6] as bool,
      deleted: fields[7] as bool,
      version: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ReviewLog obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cardId)
      ..writeByte(2)
      ..write(obj.reviewedAt)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.syncId)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.dirty)
      ..writeByte(7)
      ..write(obj.deleted)
      ..writeByte(8)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
