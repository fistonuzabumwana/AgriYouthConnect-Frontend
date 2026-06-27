import 'package:flutter/material.dart';
import 'package:agriyouthconnect/data/datasources/hive_cache_service.dart';
import 'package:agriyouthconnect/data/models/training_article_model.dart';
import 'package:agriyouthconnect/domain/repositories/training_repository.dart';

/// TrainingKnowledgeProvider manages tutorials queries, category filters,
/// and saving guides directly to local persistent boxes.
class TrainingKnowledgeProvider extends ChangeNotifier {
  final TrainingRepository trainingRepository;

  List<TrainingArticleModel> _articles = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategory;

  TrainingKnowledgeProvider({required this.trainingRepository}) {
    fetchArticles();
  }

  List<TrainingArticleModel> get articles => _articles;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  /// Loads training guides based on selected category and text queries.
  Future<void> fetchArticles({String? category, String? query}) async {
    _isLoading = true;
    if (category != null || category == null) {
      _selectedCategory = category;
    }
    if (query != null) {
      _searchQuery = query;
    }
    notifyListeners();

    try {
      final list = await trainingRepository.getTrainingArticles(cropCategory: _selectedCategory);
      
      final filter = _searchQuery.trim().toLowerCase();
      if (filter.isNotEmpty) {
        _articles = list.where((item) {
          return item.title.toLowerCase().contains(filter) ||
              item.body.toLowerCase().contains(filter);
        }).toList();
      } else {
        _articles = list;
      }
    } catch (_) {
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggles the offline availability download of a guide and persists to Hive box.
  Future<void> toggleOfflineSave(String articleId) async {
    final box = HiveCacheService.cachedArticlesBox;
    final article = box.get(articleId);

    if (article != null) {
      // Toggle value locally
      final updated = article.copyWith(
        isOfflineAvailable: !article.isOfflineAvailable,
        lastSynced: DateTime.now(),
      );
      await box.put(articleId, updated);
      
      // Refresh current states
      await fetchArticles(category: _selectedCategory, query: _searchQuery);
    }
  }

  /// Refreshes all articles from mock remote API.
  Future<void> syncAllForOffline() async {
    _isLoading = true;
    notifyListeners();

    try {
      await trainingRepository.syncTrainingArticlesForOffline();
      await fetchArticles();
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
