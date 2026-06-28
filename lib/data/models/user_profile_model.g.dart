// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 0;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      name: fields[0] as String,
      district: fields[1] as String,
      sector: fields[2] as String,
      cropType: fields[3] as String,
      farmSize: fields[4] as double,
      experienceLevel: fields[5] as String,
      role: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.district)
      ..writeByte(2)
      ..write(obj.sector)
      ..writeByte(3)
      ..write(obj.cropType)
      ..writeByte(4)
      ..write(obj.farmSize)
      ..writeByte(5)
      ..write(obj.experienceLevel)
      ..writeByte(6)
      ..write(obj.role);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
