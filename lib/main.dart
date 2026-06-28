import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Localization and Theme imports
import 'package:agriyouthconnect/core/localization/app_localizations.dart';
import 'package:agriyouthconnect/core/theme/app_theme.dart';

// Data sources and Repositories imports
import 'package:agriyouthconnect/core/network/api_client.dart';
import 'package:agriyouthconnect/core/sync/sync_queue_service.dart';
import 'package:agriyouthconnect/data/datasources/hive_cache_service.dart';
import 'package:agriyouthconnect/data/datasources/local/secure_storage_service.dart';
import 'package:agriyouthconnect/data/datasources/remote/remote_market_datasource.dart';
import 'package:agriyouthconnect/data/datasources/remote/remote_knowledge_datasource.dart';
import 'package:agriyouthconnect/data/repositories/user_repository_impl.dart';
import 'package:agriyouthconnect/data/repositories/market_repository_impl.dart';
import 'package:agriyouthconnect/data/repositories/training_repository_impl.dart';

// Presentation State Providers imports
import 'package:agriyouthconnect/presentation/providers/auth_provider.dart';
import 'package:agriyouthconnect/presentation/providers/profile_provider.dart';
import 'package:agriyouthconnect/presentation/providers/market_price_provider.dart';
import 'package:agriyouthconnect/presentation/providers/training_knowledge_provider.dart';

import 'package:agriyouthconnect/presentation/screens/login_screen.dart';

// UI Screens and Layouts
import 'package:agriyouthconnect/presentation/screens/market_board_screen.dart';
import 'package:agriyouthconnect/presentation/screens/registration_screen.dart';
import 'package:agriyouthconnect/presentation/screens/knowledge_hub_screen.dart';
import 'package:agriyouthconnect/presentation/widgets/main_app_layout.dart';

void main() async {
  // Ensure framework services are initialized for Hive path access
  WidgetsFlutterBinding.ensureInitialized();
  
  // Safe initialization of local caches
  await HiveCacheService.init();

  // Core Service Injections
  final secureStorage = SecureStorageService();
  final apiClient = ApiClient(secureStorageService: secureStorage);

  // Initialize and run the Background Sync Queue Service
  final syncService = SyncQueueService(apiClient: apiClient);
  syncService.start();

  runApp(
    LocaleProvider(
      notifier: LocaleNotifier(),
      child: MyApp(
        apiClient: apiClient,
        secureStorage: secureStorage,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final SecureStorageService secureStorage;

  const MyApp({
    super.key,
    required this.apiClient,
    required this.secureStorage,
  });

  @override
  Widget build(BuildContext context) {
    // Read the current locale from the LocaleProvider InheritedNotifier
    final localeNotifier = LocaleProvider.of(context);

    // Dynamic Remote DataSource injections
    final remoteMarketDataSource = RemoteMarketDataSource(apiClient: apiClient);
    final remoteKnowledgeDataSource = RemoteKnowledgeDataSource(apiClient: apiClient);

    // Repository injections linking remote API connections + local Hive database caches
    final userRepository = UserRepositoryImpl(apiClient: apiClient);
    final marketRepository = MarketRepositoryImpl(remoteDataSource: remoteMarketDataSource);
    final trainingRepository = TrainingRepositoryImpl(remoteDataSource: remoteKnowledgeDataSource);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            apiClient: apiClient,
            secureStorageService: secureStorage,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(userRepository: userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketPriceProvider(marketRepository: marketRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TrainingKnowledgeProvider(trainingRepository: trainingRepository),
        ),
      ],
      child: MaterialApp(
        title: 'AgriYouthConnectAI',
        debugShowCheckedModeBanner: false,
        
        // Accessibility-first theme configurations
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light, // Optimized for direct sunlight conditions

        // Localization delegators
        locale: localeNotifier.locale,
        supportedLocales: const [
          Locale('en'),
          Locale('rw'),
        ],
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          RwMaterialLocalizationsDelegate(),
          RwCupertinoLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isAuthenticated
                ? const AppHomeShell()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}

/// AppHomeShell manages the navigation state between registration, market, and tutorials tabs.
class AppHomeShell extends StatefulWidget {
  const AppHomeShell({super.key});

  @override
  State<AppHomeShell> createState() => _AppHomeShellState();
}

class _AppHomeShellState extends State<AppHomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    RegistrationScreen(),
    MarketBoardScreen(),
    KnowledgeHubScreen(),
  ];

  String _getScreenTitle(int index, AppLocalizations l10n) {
    switch (index) {
      case 0:
        return l10n.registrationTitle;
      case 1:
        return l10n.marketPrices;
      case 2:
        return l10n.knowledgeHub;
      default:
        return 'AgriYouthConnectAI';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MainAppLayout(
      title: _getScreenTitle(_currentIndex, l10n),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white24 : Colors.black,
              width: 2.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: isDark ? Colors.white60 : Colors.black54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          iconSize: 28,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_add),
              activeIcon: const Icon(Icons.person_add, size: 30),
              label: l10n.networking,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.monetization_on),
              activeIcon: const Icon(Icons.monetization_on, size: 30),
              label: l10n.marketPrices,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.school),
              activeIcon: const Icon(Icons.school, size: 30),
              label: l10n.knowledgeHub,
            ),
          ],
        ),
      ),
    );
  }
}
