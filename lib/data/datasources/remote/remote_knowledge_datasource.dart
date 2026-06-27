import 'package:agriyouthconnect/core/network/api_client.dart';
import 'package:agriyouthconnect/data/models/training_article_model.dart';

/// RemoteKnowledgeDataSource queries Node.js agricultural tutorials and guides.
class RemoteKnowledgeDataSource {
  final ApiClient _apiClient;

  RemoteKnowledgeDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get training articles filtered optionally by crop category
  Future<List<TrainingArticleModel>> getTrainingArticles({String? cropCategory}) async {
    final queryParameters = <String, dynamic>{};
    if (cropCategory != null && cropCategory.trim().isNotEmpty) {
      queryParameters['category'] = cropCategory.trim();
    }

    final response = await _apiClient.get(
      '/training',
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final list = response.data as List<dynamic>;
      return list.map((json) => TrainingArticleModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load training articles from remote server.');
    }
  }
}
