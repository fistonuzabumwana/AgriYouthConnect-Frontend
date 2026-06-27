import 'package:hive_flutter/hive_flutter.dart';
import 'package:agriyouthconnect/data/models/user_profile_model.dart';
import 'package:agriyouthconnect/data/models/market_price_model.dart';
import 'package:agriyouthconnect/data/models/training_article_model.dart';

/// HiveCacheService manages the local offline storage boxes for the app.
class HiveCacheService {
  static const String userProfileBoxName = 'user_profile_box';
  static const String marketPricesBoxName = 'market_prices_box';
  static const String cachedArticlesBoxName = 'cached_articles_box';
  static const String syncSettingsBoxName = 'sync_settings_box';

  // Prevent direct instantiation
  HiveCacheService._();

  /// Initialize Hive, register type adapters, and open persistent storage boxes.
  static Future<void> init() async {
    // 1. Initialize Hive with Flutter local directories
    await Hive.initFlutter();

    // 2. Register generated adapters safely
    _registerAdapterSafely(UserProfileModelAdapter());
    _registerAdapterSafely(MarketPriceModelAdapter());
    _registerAdapterSafely(TrainingArticleModelAdapter());

    // 3. Open boxes for persistent storage
    await Hive.openBox<UserProfileModel>(userProfileBoxName);
    await Hive.openBox<MarketPriceModel>(marketPricesBoxName);
    await Hive.openBox<TrainingArticleModel>(cachedArticlesBoxName);
    await Hive.openBox(syncSettingsBoxName);
  }

  static void _registerAdapterSafely<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  // --- Box getters ---

  static Box<UserProfileModel> get userProfileBox =>
      Hive.box<UserProfileModel>(userProfileBoxName);

  static Box<MarketPriceModel> get marketPricesBox =>
      Hive.box<MarketPriceModel>(marketPricesBoxName);

  static Box<TrainingArticleModel> get cachedArticlesBox =>
      Hive.box<TrainingArticleModel>(cachedArticlesBoxName);

  static Box get syncSettingsBox =>
      Hive.box(syncSettingsBoxName);

  /// Helper to clear all local data (useful for profile resets or testing resets)
  static Future<void> clearAll() async {
    await userProfileBox.clear();
    await marketPricesBox.clear();
    await cachedArticlesBox.clear();
    await syncSettingsBox.clear();
  }
}
