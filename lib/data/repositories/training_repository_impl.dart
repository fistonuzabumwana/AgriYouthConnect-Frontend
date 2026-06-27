import 'package:agriyouthconnect/data/datasources/hive_cache_service.dart';
import 'package:agriyouthconnect/data/datasources/mock_api_provider.dart';
import 'package:agriyouthconnect/data/datasources/remote/remote_knowledge_datasource.dart';
import 'package:agriyouthconnect/data/models/training_article_model.dart';
import 'package:agriyouthconnect/domain/repositories/training_repository.dart';

class TrainingRepositoryImpl implements TrainingRepository {
  final RemoteKnowledgeDataSource? _remoteDataSource;

  TrainingRepositoryImpl({RemoteKnowledgeDataSource? remoteDataSource}) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<TrainingArticleModel>> getTrainingArticles({String? cropCategory}) async {
    final box = HiveCacheService.cachedArticlesBox;

    // 1. Attempt updating cache from Node.js Gateway endpoint
    if (_remoteDataSource != null) {
      try {
        final serverArticles = await _remoteDataSource!.getTrainingArticles(cropCategory: cropCategory);
        for (final serverArticle in serverArticles) {
          final localArticle = box.get(serverArticle.id);
          if (localArticle != null) {
            // Preserve user offline bookmark preferences
            final merged = serverArticle.copyWith(
              isOfflineAvailable: localArticle.isOfflineAvailable,
            );
            await box.put(serverArticle.id, merged);
          } else {
            await box.put(serverArticle.id, serverArticle);
          }
        }
      } catch (_) {
        // Fail silently to serve existing Hive local cache
      }
    } else {
      // Backward-compatible fallback simulation for unit tests using MockApiProvider
      if (MockApiProvider.isOnline) {
        try {
          final serverArticles = await MockApiProvider.fetchTrainingArticles();
          for (final serverArticle in serverArticles) {
            final localArticle = box.get(serverArticle.id);
            if (localArticle != null) {
              final merged = serverArticle.copyWith(
                isOfflineAvailable: localArticle.isOfflineAvailable,
              );
              await box.put(serverArticle.id, merged);
            } else {
              await box.put(serverArticle.id, serverArticle);
            }
          }
        } catch (_) {}
      }
    }

    // 2. Fetch all local cached elements
    List<TrainingArticleModel> articles = box.values.toList();

    // 3. Seed offline fallbacks on fresh offline installs
    if (articles.isEmpty) {
      final seed = _getSeededArticles();
      for (final article in seed) {
        await box.put(article.id, article);
      }
      articles = seed;
    }

    // 4. Apply crop category filtering matching locally
    if (cropCategory != null && cropCategory.isNotEmpty) {
      final query = cropCategory.toLowerCase();
      articles = articles.where((element) => element.cropCategory.toLowerCase() == query).toList();
    }

    return articles;
  }

  @override
  Future<TrainingArticleModel?> getTrainingArticleById(String id) async {
    final box = HiveCacheService.cachedArticlesBox;
    if (box.containsKey(id)) {
      return box.get(id);
    }

    if (_remoteDataSource != null) {
      try {
        final articles = await _remoteDataSource!.getTrainingArticles();
        final match = articles.firstWhere((element) => element.id == id);
        await box.put(match.id, match);
        return match;
      } catch (_) {}
    } else {
      if (MockApiProvider.isOnline) {
        try {
          final articles = await MockApiProvider.fetchTrainingArticles();
          final match = articles.firstWhere((element) => element.id == id);
          await box.put(match.id, match);
          return match;
        } catch (_) {}
      }
    }
    return null;
  }

  @override
  Future<void> syncTrainingArticlesForOffline() async {
    final box = HiveCacheService.cachedArticlesBox;

    if (_remoteDataSource != null) {
      final serverArticles = await _remoteDataSource!.getTrainingArticles();
      for (final article in serverArticles) {
        final offlineArticle = article.copyWith(isOfflineAvailable: true);
        await box.put(article.id, offlineArticle);
      }
    } else {
      if (!MockApiProvider.isOnline) {
        throw Exception('Sync failed: device is offline.');
      }
      final serverArticles = await MockApiProvider.fetchTrainingArticles();
      for (final article in serverArticles) {
        final offlineArticle = article.copyWith(isOfflineAvailable: true);
        await box.put(article.id, offlineArticle);
      }
    }
  }

  List<TrainingArticleModel> _getSeededArticles() {
    final now = DateTime.now();
    return [
      TrainingArticleModel(
        id: '1',
        title: 'Maize Planting and Spacing Guidelines',
        body: 'Optimal maize spacing is crucial for high yields. Plant seeds at a depth of 5cm, spacing rows 75cm apart with 25cm between individual plants. This guarantees sufficient direct sunlight and prevents weed overgrowth. Apply organic fertilizer during land preparation and top-dress with Urea at 3-4 weeks.',
        cropCategory: 'Maize',
        readTimeMins: 4,
        isOfflineAvailable: true,
        lastSynced: now,
      ),
      TrainingArticleModel(
        id: '2',
        title: 'Fighting Bean Stem Maggot & Pests',
        body: 'Address bean stem maggot is a major pest for Rwandan farmers. Protect your beans by crop rotation with maize or potatoes, planting early in the wet season, and applying systemic organic pesticides when young shoots emerge. Keep soil well-aerated.',
        cropCategory: 'Beans',
        readTimeMins: 6,
        isOfflineAvailable: true,
        lastSynced: now,
      ),
    ];
  }
}
