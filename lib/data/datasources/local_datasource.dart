import 'package:agriyouthconnect/data/models/market_price_model.dart';
import 'package:agriyouthconnect/data/models/training_article_model.dart';
import 'package:agriyouthconnect/data/models/user_profile_model.dart';

/// LocalDataSource simulates offline caching and database synchronization.
/// In a production environment, this is replaced by Hive, SQLite, or SharedPreferences.
class LocalDataSource {
  // Simple in-memory storage to simulate SQLite / Hive
  UserProfileModel? _cachedProfile;
  final List<MarketPriceModel> _cachedMarketPrices = [];
  final List<TrainingArticleModel> _cachedTrainingArticles = [];

  LocalDataSource() {
    _populateSeedData();
  }

  /// Seed mock data representing real-world conditions in Rwanda.
  void _populateSeedData() {
    // Seed Market Prices
    _cachedMarketPrices.addAll([
      MarketPriceModel(
        cropName: 'Maize',
        pricePerKg: 350.0,
        marketName: 'Kimironko Market',
        district: 'Gasabo',
        trend: 'rising',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      MarketPriceModel(
        cropName: 'Maize',
        pricePerKg: 330.0,
        marketName: 'Musanze central Market',
        district: 'Musanze',
        trend: 'stable',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      MarketPriceModel(
        cropName: 'Beans',
        pricePerKg: 680.0,
        marketName: 'Nyabugogo Market',
        district: 'Nyarugenge',
        trend: 'falling',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      MarketPriceModel(
        cropName: 'Beans',
        pricePerKg: 650.0,
        marketName: 'Rubavu Market',
        district: 'Rubavu',
        trend: 'rising',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      MarketPriceModel(
        cropName: 'Coffee',
        pricePerKg: 2800.0,
        marketName: 'Huye Coffee Station',
        district: 'Huye',
        trend: 'stable',
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MarketPriceModel(
        cropName: 'Irish Potatoes',
        pricePerKg: 450.0,
        marketName: 'Musanze central Market',
        district: 'Musanze',
        trend: 'rising',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      MarketPriceModel(
        cropName: 'Irish Potatoes',
        pricePerKg: 420.0,
        marketName: 'Rubavu Market',
        district: 'Rubavu',
        trend: 'falling',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ]);

    // Seed Training Articles (English & Kinyarwanda bodies are bundled for demonstration)
    _cachedTrainingArticles.addAll([
      TrainingArticleModel(
        id: '1',
        title: 'Maize Planting and Spacing Guidelines',
        body: 'Optimal maize spacing is crucial for high yields. Plant seeds at a depth of 5cm, spacing rows 75cm apart with 25cm between individual plants. This guarantees sufficient direct sunlight and prevents weed overgrowth. Apply organic fertilizer during land preparation and top-dress with Urea at 3-4 weeks.',
        cropCategory: 'Maize',
        readTimeMins: 4,
        isOfflineAvailable: true,
        lastSynced: DateTime.now(),
      ),
      TrainingArticleModel(
        id: '2',
        title: 'Fighting Bean Stem Maggot & Pests',
        body: 'Bean stem maggot is a major pest for Rwandan farmers. Protect your beans by crop rotation with maize or potatoes, planting early in the wet season, and applying systemic organic pesticides when young shoots emerge. Keep soil well-aerated.',
        cropCategory: 'Beans',
        readTimeMins: 6,
        isOfflineAvailable: true,
        lastSynced: DateTime.now(),
      ),
      TrainingArticleModel(
        id: '3',
        title: 'Coffee Pruning & Canopy Management',
        body: 'Proper coffee tree pruning maximizes coffee cherry quality. Prune dead branches immediately after harvest. Keep trees at a manageable height of 1.8 to 2 meters. Mulch heavily to conserve soil moisture in the dry season.',
        cropCategory: 'Coffee',
        readTimeMins: 8,
        isOfflineAvailable: false,
        lastSynced: DateTime.now(),
      ),
      TrainingArticleModel(
        id: '4',
        title: 'Irish Potatoes Late Blight Control',
        body: 'Late Blight thrives in high-humidity areas like Musanze and Rubavu. Avoid blight by planting certified clean seeds, practicing crop rotation, and applying fungicide protective sprays weekly during humid rains.',
        cropCategory: 'Irish Potatoes',
        readTimeMins: 5,
        isOfflineAvailable: true,
        lastSynced: DateTime.now(),
      ),
    ]);
  }

  // --- Profile Storage ---
  Future<UserProfileModel?> getCachedProfile() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate database query delay
    return _cachedProfile;
  }

  Future<bool> cacheProfile(UserProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cachedProfile = profile;
    return true;
  }

  Future<void> clearCachedProfile() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _cachedProfile = null;
  }

  // --- Market Prices Storage ---
  Future<List<MarketPriceModel>> getCachedMarketPrices() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_cachedMarketPrices);
  }

  Future<void> updateMarketPrices(List<MarketPriceModel> freshPrices) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _cachedMarketPrices.clear();
    _cachedMarketPrices.addAll(freshPrices);
  }

  // --- Training Articles Storage ---
  Future<List<TrainingArticleModel>> getCachedTrainingArticles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_cachedTrainingArticles);
  }

  Future<void> updateTrainingArticles(List<TrainingArticleModel> freshArticles) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cachedTrainingArticles.clear();
    _cachedTrainingArticles.addAll(freshArticles);
  }
}
