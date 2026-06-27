import 'package:flutter/material.dart';
import 'package:agriyouthconnect/data/datasources/mock_api_provider.dart';
import 'package:agriyouthconnect/data/models/market_price_model.dart';
import 'package:agriyouthconnect/domain/repositories/market_repository.dart';

/// MarketPriceProvider handles wholesale prices fetching, filtering by district,
/// and reactive connection updates.
class MarketPriceProvider extends ChangeNotifier {
  final MarketRepository marketRepository;

  List<MarketPriceModel> _prices = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _currentFilterDistrict = '';

  MarketPriceProvider({required this.marketRepository}) {
    fetchPrices();
  }

  List<MarketPriceModel> get prices => _prices;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get currentFilterDistrict => _currentFilterDistrict;
  bool get isOfflineMode => !MockApiProvider.isOnline;

  /// Fetches prices from repository (applies online/offline checks internally).
  Future<void> fetchPrices({String? district}) async {
    _isLoading = true;
    _errorMessage = '';
    if (district != null) {
      _currentFilterDistrict = district;
    }
    notifyListeners();

    try {
      _prices = await marketRepository.getMarketPrices(district: _currentFilterDistrict);
    } catch (e) {
      _errorMessage = 'Failed to load prices: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Manually triggers a reload, forcing remote calls if online.
  Future<void> refreshPrices() async {
    try {
      await marketRepository.refreshMarketPrices();
      await fetchPrices();
    } catch (e) {
      _errorMessage = e.toString().contains('offline')
          ? 'Device is offline. Serving local cache.'
          : 'Failed to refresh prices.';
      await fetchPrices();
    }
  }

  /// Toggles global mock network connectivity state and reloads.
  void toggleMockConnectivity() {
    MockApiProvider.isOnline = !MockApiProvider.isOnline;
    refreshPrices();
  }
}
