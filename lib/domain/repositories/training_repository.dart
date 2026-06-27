import 'package:agriyouthconnect/data/models/training_article_model.dart';

/// Abstract contract for managing training articles and guides.
abstract class TrainingRepository {
  /// Fetches available guides, optionally filtering by crop category (e.g. Maize, Coffee).
  Future<List<TrainingArticleModel>> getTrainingArticles({String? cropCategory});

  /// Retrieves a specific training guide by its ID.
  Future<TrainingArticleModel?> getTrainingArticleById(String id);

  /// Downloads and caches active articles for offline usage in areas with poor network.
  Future<void> syncTrainingArticlesForOffline();
}
