// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostAdapter extends TypeAdapter<Post> {
  @override
  final int typeId = 0;

  @override
  Post read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Post(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      rawText: fields[2] as String,
      normalizedText: fields[3] as String,
      createdAt: fields[4] as DateTime,
      likeCount: fields[5] as int,
      learnedCount: fields[6] as int,
      learned: fields[7] as bool,
      syncId: fields[8] as String?,
      updatedAt: fields[9] as DateTime?,
      dirty: fields[10] as bool,
      deleted: fields[11] as bool,
      version: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Post obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.rawText)
      ..writeByte(3)
      ..write(obj.normalizedText)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.likeCount)
      ..writeByte(6)
      ..write(obj.learnedCount)
      ..writeByte(7)
      ..write(obj.learned)
      ..writeByte(8)
      ..write(obj.syncId)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.dirty)
      ..writeByte(11)
      ..write(obj.deleted)
      ..writeByte(12)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
