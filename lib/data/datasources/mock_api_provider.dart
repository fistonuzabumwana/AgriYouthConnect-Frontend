import 'dart:io';
import 'package:agriyouthconnect/data/models/market_price_model.dart';
import 'package:agriyouthconnect/data/models/training_article_model.dart';
import 'package:agriyouthconnect/data/models/user_profile_model.dart';

/// MockApiProvider represents a simulated HTTP REST backend API client.
/// Exposes a global static network toggle `isOnline` to simulate airplane mode.
class MockApiProvider {
  // Global network toggle to test offline fallbacks
  static bool isOnline = true;

  // Prevent direct instantiation
  MockApiProvider._();

  /// Helper to execute network delays, bypassed in unit tests
  static Future<void> _delay(int milliseconds) async {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      await Future.delayed(Duration(milliseconds: milliseconds));
    }
  }

  /// Simulate a REST call to save the user profile on the server.
  static Future<UserProfileModel> registerUserProfile(UserProfileModel profile) async {
    await _delay(600); // Network delay
    if (!isOnline) {
      throw Exception('Network connection failed. Device is offline.');
    }
    return profile;
  }

  /// Simulate fetching real-time market prices from the backend.
  static Future<List<MarketPriceModel>> fetchMarketPrices() async {
    await _delay(700);
    if (!isOnline) {
      throw Exception('Network connection failed. Device is offline.');
    }

    final now = DateTime.now();

    return [
      MarketPriceModel(
        cropName: 'Maize',
        pricePerKg: 360.0,
        previousPrice: 340.0,
        marketName: 'Kimironko Market',
        district: 'Gasabo',
        trend: 'rising',
        lastUpdated: now.subtract(const Duration(minutes: 30)),
      ),
      MarketPriceModel(
        cropName: 'Maize',
        pricePerKg: 330.0,
        previousPrice: 330.0,
        marketName: 'Musanze central Market',
        district: 'Musanze',
        trend: 'stable',
        lastUpdated: now.subtract(const Duration(hours: 2)),
      ),
      MarketPriceModel(
        cropName: 'Beans',
        pricePerKg: 640.0,
        previousPrice: 680.0,
        marketName: 'Nyabugogo Market',
        district: 'Nyarugenge',
        trend: 'falling',
        lastUpdated: now.subtract(const Duration(minutes: 15)),
      ),
      MarketPriceModel(
        cropName: 'Beans',
        pricePerKg: 670.0,
        previousPrice: 650.0,
        marketName: 'Rubavu Market',
        district: 'Rubavu',
        trend: 'rising',
        lastUpdated: now.subtract(const Duration(hours: 1)),
      ),
      MarketPriceModel(
        cropName: 'Coffee',
        pricePerKg: 2950.0,
        previousPrice: 2950.0,
        marketName: 'Huye Coffee Station',
        district: 'Huye',
        trend: 'stable',
        lastUpdated: now.subtract(const Duration(hours: 6)),
      ),
      MarketPriceModel(
        cropName: 'Irish Potatoes',
        pricePerKg: 460.0,
        previousPrice: 420.0,
        marketName: 'Musanze central Market',
        district: 'Musanze',
        trend: 'rising',
        lastUpdated: now.subtract(const Duration(minutes: 10)),
      ),
      MarketPriceModel(
        cropName: 'Irish Potatoes',
        pricePerKg: 410.0,
        previousPrice: 430.0,
        marketName: 'Rubavu Market',
        district: 'Rubavu',
        trend: 'falling',
        lastUpdated: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }

  /// Simulate fetching training guides from the server.
  static Future<List<TrainingArticleModel>> fetchTrainingArticles() async {
    await _delay(500);
    if (!isOnline) {
      throw Exception('Network connection failed. Device is offline.');
    }

    final now = DateTime.now();

    return [
      TrainingArticleModel(
        id: '1',
        title: 'Maize Planting and Spacing Guidelines',
        body: 'Optimal maize spacing is crucial for high yields. Plant seeds at a depth of 5cm, spacing rows 75cm apart with 25cm between individual plants. This guarantees sufficient direct sunlight and prevents weed overgrowth. Apply organic fertilizer during land preparation and top-dress with Urea at 3-4 weeks.',
        cropCategory: 'Maize',
        readTimeMins: 4,
        isOfflineAvailable: false,
        lastSynced: now,
      ),
      TrainingArticleModel(
        id: '2',
        title: 'Fighting Bean Stem Maggot & Pests',
        body: 'Bean stem maggot is a major pest for Rwandan farmers. Protect your beans by crop rotation with maize or potatoes, planting early in the wet season, and applying systemic organic pesticides when young shoots emerge. Keep soil well-aerated.',
        cropCategory: 'Beans',
        readTimeMins: 6,
        isOfflineAvailable: false,
        lastSynced: now,
      ),
      TrainingArticleModel(
        id: '3',
        title: 'Coffee Pruning & Canopy Management',
        body: 'Proper coffee tree pruning maximizes coffee cherry quality. Prune dead branches immediately after harvest. Keep trees at a manageable height of 1.8 to 2 meters. Mulch heavily to conserve soil moisture in the dry season.',
        cropCategory: 'Coffee',
        readTimeMins: 8,
        isOfflineAvailable: false,
        lastSynced: now,
      ),
      TrainingArticleModel(
        id: '4',
        title: 'Irish Potatoes Late Blight Control',
        body: 'Late Blight thrives in high-humidity areas like Musanze and Rubavu. Avoid blight by planting certified clean seeds, practicing crop rotation, and applying fungicide protective sprays weekly during humid rains.',
        cropCategory: 'Irish Potatoes',
        readTimeMins: 5,
        isOfflineAvailable: false,
        lastSynced: now,
      ),
    ];
  }
}
