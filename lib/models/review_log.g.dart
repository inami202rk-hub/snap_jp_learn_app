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
    );
  }

  @override
  void write(BinaryWriter writer, ReviewLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cardId)
      ..writeByte(2)
      ..write(obj.reviewedAt)
      ..writeByte(3)
      ..write(obj.rating);
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
