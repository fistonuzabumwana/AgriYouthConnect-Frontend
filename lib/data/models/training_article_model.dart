import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'training_article_model.g.dart';

/// Represents an agricultural training article/guide in the Knowledge Hub.
@HiveType(typeId: 2)
class TrainingArticleModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String body;
  @HiveField(3)
  final String cropCategory;
  @HiveField(4)
  final int readTimeMins;
  @HiveField(5)
  final bool isOfflineAvailable;
  @HiveField(6)
  final DateTime lastSynced;

  const TrainingArticleModel({
    required this.id,
    required this.title,
    required this.body,
    required this.cropCategory,
    required this.readTimeMins,
    this.isOfflineAvailable = false,
    required this.lastSynced,
  });

  /// Converts the training article to a JSON map for local caching.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'cropCategory': cropCategory,
      'readTimeMins': readTimeMins,
      'isOfflineAvailable': isOfflineAvailable,
      'lastSynced': lastSynced.toIso8601String(),
    };
  }

  /// Restores training article from cache.
  factory TrainingArticleModel.fromJson(Map<String, dynamic> json) {
    return TrainingArticleModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      cropCategory: json['cropCategory'] as String? ?? '',
      readTimeMins: json['readTimeMins'] as int? ?? 5,
      isOfflineAvailable: json['isOfflineAvailable'] as bool? ?? false,
      lastSynced: json['lastSynced'] != null
          ? DateTime.parse(json['lastSynced'] as String)
          : DateTime.now(),
    );
  }

  /// Returns a copy of this object with optionally updated fields.
  TrainingArticleModel copyWith({
    String? id,
    String? title,
    String? body,
    String? cropCategory,
    int? readTimeMins,
    bool? isOfflineAvailable,
    DateTime? lastSynced,
  }) {
    return TrainingArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      cropCategory: cropCategory ?? this.cropCategory,
      readTimeMins: readTimeMins ?? this.readTimeMins,
      isOfflineAvailable: isOfflineAvailable ?? this.isOfflineAvailable,
      lastSynced: lastSynced ?? this.lastSynced,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        cropCategory,
        readTimeMins,
        isOfflineAvailable,
        lastSynced,
      ];
}
