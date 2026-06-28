import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user_profile_model.g.dart';

/// Represents a Rwandan farmer's registration profile details.
@HiveType(typeId: 0)
class UserProfileModel extends Equatable {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String district;
  @HiveField(2)
  final String sector;
  @HiveField(3)
  final String cropType;
  @HiveField(4)
  final double farmSize; // in Hectares
  @HiveField(5)
  final String experienceLevel;
  @HiveField(6)
  final String role;

  const UserProfileModel({
    required this.name,
    required this.district,
    required this.sector,
    required this.cropType,
    required this.farmSize,
    required this.experienceLevel,
    this.role = 'FARMER',
  });

  /// Converts the profile model to a JSON map for local caching.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'district': district,
      'sector': sector,
      'cropType': cropType,
      'farmSize': farmSize,
      'experienceLevel': experienceLevel,
      'role': role,
    };
  }

  /// Restores a profile model from a JSON map cache.
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] as String? ?? '',
      district: json['district'] as String? ?? '',
      sector: json['sector'] as String? ?? '',
      cropType: json['cropType'] as String? ?? '',
      farmSize: (json['farmSize'] as num? ?? 0.0).toDouble(),
      experienceLevel: json['experienceLevel'] as String? ?? '',
      role: json['role'] as String? ?? 'FARMER',
    );
  }

  /// Returns a copy of this object with optionally updated fields.
  UserProfileModel copyWith({
    String? name,
    String? district,
    String? sector,
    String? cropType,
    double? farmSize,
    String? experienceLevel,
    String? role,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      district: district ?? this.district,
      sector: sector ?? this.sector,
      cropType: cropType ?? this.cropType,
      farmSize: farmSize ?? this.farmSize,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
        name,
        district,
        sector,
        cropType,
        farmSize,
        experienceLevel,
        role,
      ];
}
