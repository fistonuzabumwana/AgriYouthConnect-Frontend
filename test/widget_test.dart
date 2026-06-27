import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:agriyouthconnect/main.dart';
import 'package:agriyouthconnect/core/localization/app_localizations.dart';
import 'package:agriyouthconnect/core/network/api_client.dart';
import 'package:agriyouthconnect/data/datasources/hive_cache_service.dart';
import 'package:agriyouthconnect/data/datasources/local/secure_storage_service.dart';
import 'package:agriyouthconnect/data/models/user_profile_model.dart';
import 'package:agriyouthconnect/data/models/market_price_model.dart';
import 'package:agriyouthconnect/data/models/training_article_model.dart';
import 'package:agriyouthconnect/presentation/widgets/custom_button.dart';
import 'package:agriyouthconnect/presentation/widgets/custom_text_field.dart';

/// Global mock overrides to block network connections and pool handles in tests
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => MockHttpClient();
}

/// Universal mock HTTP client using noSuchMethod dynamic dispatch
class MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// In-memory mock storage class to bypass native platform channel calls in tests
class MockFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _memoryStore = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _memoryStore[key] = value;
    } else {
      _memoryStore.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _memoryStore[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _memoryStore.remove(key);
  }
}

void main() {
  late Directory tempDir;
  late SecureStorageService secureStorage;
  late ApiClient apiClient;

  setUpAll(() async {
    // 1. Inject HTTP overrides to stop socket pool allocations
    HttpOverrides.global = MockHttpOverrides();

    // 2. Initialize Hive in a mock system directory for testing
    tempDir = Directory.systemTemp.createTempSync('hive_test_dir');
    Hive.init(tempDir.path);

    // 3. Register type adapters manually
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MarketPriceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TrainingArticleModelAdapter());
    }

    // 4. Pre-open boxes in the test context
    await Hive.openBox<UserProfileModel>(HiveCacheService.userProfileBoxName);
    await Hive.openBox<MarketPriceModel>(HiveCacheService.marketPricesBoxName);
    await Hive.openBox<TrainingArticleModel>(HiveCacheService.cachedArticlesBoxName);
    await Hive.openBox(HiveCacheService.syncSettingsBoxName);

    // 5. Initialize mock secure storage and client services
    final mockSecureStorage = MockFlutterSecureStorage();
    secureStorage = SecureStorageService(storage: mockSecureStorage);
    apiClient = ApiClient(secureStorageService: secureStorage);
  });

  tearDownAll(() async {
    // Safely close Hive database files and Dio connection pools to release handles
    try {
      apiClient.close();
      await Hive.close();
    } catch (_) {}
  });

  group('1. Localization Infrastructure Tests', () {
    test('Should translate correctly to English', () {
      final l10n = AppLocalizations(const Locale('en'));
      expect(l10n.save, 'Save');
      expect(l10n.marketPrices, 'Market Prices');
      expect(l10n.cropType, 'Primary Crop Type');
      expect(l10n.maize, 'Maize (Ibigori)');
    });

    test('Should translate correctly to Kinyarwanda', () {
      final l10n = AppLocalizations(const Locale('rw'));
      expect(l10n.save, 'Emeza');
      expect(l10n.marketPrices, 'Ibiciro ku Isoko');
      expect(l10n.cropType, 'Igihingwa Ngandorarwanda');
      expect(l10n.maize, 'Ibigori');
    });
  });

  group('2. Data Model Serialization Tests', () {
    test('UserProfileModel should correctly serialize to and from JSON', () {
      final profile = UserProfileModel(
        name: 'Gakire John',
        district: 'Musanze',
        sector: 'Kinigi',
        cropType: 'Irish Potatoes',
        farmSize: 1.5,
        experienceLevel: 'Expert',
      );

      final json = profile.toJson();
      expect(json['name'], 'Gakire John');
      expect(json['district'], 'Musanze');
      expect(json['farmSize'], 1.5);

      final restored = UserProfileModel.fromJson(json);
      expect(restored.name, 'Gakire John');
      expect(restored.district, 'Musanze');
      expect(restored.farmSize, 1.5);
    });
  });

  group('3. Presentation Layer & UX Flow Tests', () {
    testWidgets('App renders default English language shell, registration progress, and inputs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleProvider(
          notifier: LocaleNotifier(),
          child: MyApp(
            apiClient: apiClient,
            secureStorage: secureStorage,
          ),
        ),
      );
      
      // Settle loading states
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Verify layout displays active locale info
      expect(find.text('English (EN)'), findsOneWidget);

      // Verify connection toggle is rendering in the top header
      expect(find.text('Mock Sync Server:'), findsOneWidget);
      expect(find.text('Online (API Sync)'), findsOneWidget);

      // Verify that profile completion progress is initially 0%
      expect(find.text('Profile Completion:'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);

      // Enter full name and check if progress bar increments reactively
      final nameField = find.byType(CustomTextField).first;
      await tester.ensureVisible(nameField);
      await tester.enterText(nameField, 'Fiston Niyomugabo');
      await tester.pump();

      // Completion progress should increase to 20%
      expect(find.text('20%'), findsOneWidget);

      // Verify accessible button exists
      final submitButton = find.byType(CustomButton);
      await tester.ensureVisible(submitButton);
      expect(submitButton, findsOneWidget);
    });

    testWidgets('District dropdown selection updates Sector selection cascade matrix',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleProvider(
          notifier: LocaleNotifier(),
          child: MyApp(
            apiClient: apiClient,
            secureStorage: secureStorage,
          ),
        ),
      );
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Sector field should initially say "Select District First"
      expect(find.text('Select District First'), findsOneWidget);

      // Find and select the District Dropdown
      final districtDropdown = find.byType(DropdownButtonFormField<String>).first;
      await tester.ensureVisible(districtDropdown);
      await tester.tap(districtDropdown);
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Choose 'Musanze' from dropdown list
      final musanzeItem = find.text('Musanze').last;
      await tester.tap(musanzeItem);
      
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // Wait for dropdown menu collapse animation to finish completely
      await tester.pump();

      // District should be set to Musanze
      expect(find.text('Musanze'), findsOneWidget);

      // Sector field should now enable and show "Select Sector"
      expect(find.text('Select Sector'), findsOneWidget);
    });

    testWidgets('Toggling language and network status updates states correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        LocaleProvider(
          notifier: LocaleNotifier(),
          child: MyApp(
            apiClient: apiClient,
            secureStorage: secureStorage,
          ),
        ),
      );
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Tap language switch button in the app bar to switch to Kinyarwanda
      final languageButton = find.widgetWithText(TextButton, 'RW');
      expect(languageButton, findsOneWidget);
      await tester.tap(languageButton);
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Verify Kinyarwanda translation labels
      expect(find.text('Ikinyarwanda (RW)'), findsOneWidget);
      expect(find.text('Kwandika Umuhinzi'), findsNWidgets(2));

      // Tap offline sync toggler to toggle Mock API to Offline mode
      final toggleButton = find.widgetWithText(OutlinedButton, 'TOGGLE');
      expect(toggleButton, findsOneWidget);
      await tester.tap(toggleButton);
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Verify banner reflects offline cache state
      expect(find.text('Offline (Hive)'), findsOneWidget);
    });
  });
}
