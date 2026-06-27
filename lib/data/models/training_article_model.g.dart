// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_article_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingArticleModelAdapter extends TypeAdapter<TrainingArticleModel> {
  @override
  final int typeId = 2;

  @override
  TrainingArticleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingArticleModel(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      cropCategory: fields[3] as String,
      readTimeMins: fields[4] as int,
      isOfflineAvailable: fields[5] as bool,
      lastSynced: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TrainingArticleModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.cropCategory)
      ..writeByte(4)
      ..write(obj.readTimeMins)
      ..writeByte(5)
      ..write(obj.isOfflineAvailable)
      ..writeByte(6)
      ..write(obj.lastSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingArticleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
