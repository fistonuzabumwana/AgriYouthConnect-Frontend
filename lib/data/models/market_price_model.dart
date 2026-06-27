import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'market_price_model.g.dart';

/// Represents the price details for a crop in a specific market.
@HiveType(typeId: 1)
class MarketPriceModel extends Equatable {
  @HiveField(0)
  final String cropName;
  @HiveField(1)
  final double pricePerKg; // in Rwandan Franc (RWF)
  @HiveField(2)
  final String marketName;
  @HiveField(3)
  final String district;
  @HiveField(4)
  final String trend; // 'rising', 'falling', 'stable'
  @HiveField(5)
  final DateTime lastUpdated;
  @HiveField(6)
  final double previousPrice; // in RWF to calculate/track historical trend

  const MarketPriceModel({
    required this.cropName,
    required this.pricePerKg,
    required this.marketName,
    required this.district,
    required this.trend,
    required this.lastUpdated,
    this.previousPrice = 0.0,
  });

  /// Converts the market price to a JSON map for local caching.
  Map<String, dynamic> toJson() {
    return {
      'cropName': cropName,
      'pricePerKg': pricePerKg,
      'marketName': marketName,
      'district': district,
      'trend': trend,
      'lastUpdated': lastUpdated.toIso8601String(),
      'previousPrice': previousPrice,
    };
  }

  /// Restores market price from local cache.
  factory MarketPriceModel.fromJson(Map<String, dynamic> json) {
    return MarketPriceModel(
      cropName: json['cropName'] as String? ?? '',
      pricePerKg: (json['pricePerKg'] as num? ?? 0.0).toDouble(),
      marketName: json['marketName'] as String? ?? '',
      district: json['district'] as String? ?? '',
      trend: json['trend'] as String? ?? 'stable',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      previousPrice: (json['previousPrice'] as num? ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        cropName,
        pricePerKg,
        marketName,
        district,
        trend,
        lastUpdated,
        previousPrice,
      ];
}
