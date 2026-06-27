import 'package:agriyouthconnect/data/datasources/hive_cache_service.dart';
import 'package:agriyouthconnect/data/datasources/mock_api_provider.dart';
import 'package:agriyouthconnect/data/datasources/remote/remote_market_datasource.dart';
import 'package:agriyouthconnect/data/models/market_price_model.dart';
import 'package:agriyouthconnect/domain/repositories/market_repository.dart';

class MarketRepositoryImpl implements MarketRepository {
  final RemoteMarketDataSource? _remoteDataSource;

  MarketRepositoryImpl({RemoteMarketDataSource? remoteDataSource}) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<MarketPriceModel>> getMarketPrices({String? district}) async {
    final box = HiveCacheService.marketPricesBox;

    // 1. Attempt querying Node.js Gateway service endpoint
    if (_remoteDataSource != null) {
      try {
        final serverPrices = await _remoteDataSource!.getMarketPrices(district: district);
        // Sync locally
        await box.clear();
        await box.addAll(serverPrices);
      } catch (_) {
        // Fallback to cache silently on network error
      }
    } else {
      // Backward-compatible fallback simulation for unit tests using MockApiProvider
      if (MockApiProvider.isOnline) {
        try {
          final serverPrices = await MockApiProvider.fetchMarketPrices();
          await box.clear();
          await box.addAll(serverPrices);
        } catch (_) {}
      }
    }

    // 2. Fetch local storage cached data
    List<MarketPriceModel> prices = box.values.toList();

    // 3. Populate fallback local seeds on fresh installs when offline
    if (prices.isEmpty) {
      final fallback = _getSeededFallbackPrices();
      await box.addAll(fallback);
      prices = fallback;
    }

    // 4. Perform filter matching locally
    if (district != null && district.trim().isNotEmpty) {
      final query = district.trim().toLowerCase();
      prices = prices.where((item) => item.district.toLowerCase().contains(query)).toList();
    }

    return prices;
  }

  @override
  Future<void> refreshMarketPrices() async {
    final box = HiveCacheService.marketPricesBox;
    
    if (_remoteDataSource != null) {
      final serverPrices = await _remoteDataSource!.getMarketPrices();
      await box.clear();
      await box.addAll(serverPrices);
    } else {
      if (MockApiProvider.isOnline) {
        final serverPrices = await MockApiProvider.fetchMarketPrices();
        await box.clear();
        await box.addAll(serverPrices);
      } else {
        throw Exception('Cannot refresh market prices: device is offline.');
      }
    }
  }

  List<MarketPriceModel> _getSeededFallbackPrices() {
    final now = DateTime.now();
    return [
      MarketPriceModel(
        cropName: 'Maize',
        pricePerKg: 350.0,
        previousPrice: 350.0,
        marketName: 'Kimironko Market',
        district: 'Gasabo',
        trend: 'stable',
        lastUpdated: now,
      ),
      MarketPriceModel(
        cropName: 'Beans',
        pricePerKg: 650.0,
        previousPrice: 650.0,
        marketName: 'Nyabugogo Market',
        district: 'Nyarugenge',
        trend: 'stable',
        lastUpdated: now,
      ),
      MarketPriceModel(
        cropName: 'Irish Potatoes',
        pricePerKg: 420.0,
        previousPrice: 420.0,
        marketName: 'Musanze central Market',
        district: 'Musanze',
        trend: 'stable',
        lastUpdated: now,
      ),
    ];
  }
}
