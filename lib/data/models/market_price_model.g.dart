// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_price_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarketPriceModelAdapter extends TypeAdapter<MarketPriceModel> {
  @override
  final int typeId = 1;

  @override
  MarketPriceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarketPriceModel(
      cropName: fields[0] as String,
      pricePerKg: fields[1] as double,
      marketName: fields[2] as String,
      district: fields[3] as String,
      trend: fields[4] as String,
      lastUpdated: fields[5] as DateTime,
      previousPrice: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MarketPriceModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.cropName)
      ..writeByte(1)
      ..write(obj.pricePerKg)
      ..writeByte(2)
      ..write(obj.marketName)
      ..writeByte(3)
      ..write(obj.district)
      ..writeByte(4)
      ..write(obj.trend)
      ..writeByte(5)
      ..write(obj.lastUpdated)
      ..writeByte(6)
      ..write(obj.previousPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketPriceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
