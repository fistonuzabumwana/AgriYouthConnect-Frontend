import 'package:agriyouthconnect/core/network/api_client.dart';
import 'package:agriyouthconnect/data/models/market_price_model.dart';

/// RemoteMarketDataSource handles HTTP queries to get commodity price indexes.
class RemoteMarketDataSource {
  final ApiClient _apiClient;

  RemoteMarketDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch live prices filtered optionally by local district query parameter
  Future<List<MarketPriceModel>> getMarketPrices({String? district}) async {
    final queryParameters = <String, dynamic>{};
    if (district != null && district.trim().isNotEmpty) {
      queryParameters['district'] = district.trim();
    }

    final response = await _apiClient.get(
      '/market',
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final list = response.data as List<dynamic>;
      return list.map((json) => MarketPriceModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load market prices from remote server.');
    }
  }
}
