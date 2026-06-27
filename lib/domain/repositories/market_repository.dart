import 'package:agriyouthconnect/data/models/market_price_model.dart';

/// Abstract contract for fetching market price lists and monitoring price trends.
abstract class MarketRepository {
  /// Fetches the latest available crop prices, optionally filtered by district.
  Future<List<MarketPriceModel>> getMarketPrices({String? district});

  /// Triggers a refresh of market prices from the backend or SMS channel.
  Future<void> refreshMarketPrices();
}
