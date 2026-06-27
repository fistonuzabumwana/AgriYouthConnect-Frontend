import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agriyouthconnect/core/localization/app_localizations.dart';
import 'package:agriyouthconnect/presentation/providers/market_price_provider.dart';
import 'package:agriyouthconnect/presentation/providers/training_knowledge_provider.dart';

/// MainAppLayout is the global safe-area shell wrapper.
/// It wraps views with consistent padding, adjusts for notch cutouts,
/// and includes global controllers like language switching and mock connectivity.
class MainAppLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const MainAppLayout({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final l10n = AppLocalizations.of(context);
    final localeNotifier = LocaleProvider.of(context);
    final marketProvider = Provider.of<MarketPriceProvider>(context);

    // Adaptive padding based on screen width
    double horizontalPadding = 16.0;
    if (mediaQuery.size.width > 600) {
      horizontalPadding = 32.0;
    } else if (mediaQuery.size.width > 900) {
      horizontalPadding = 64.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // Language Switcher Button (accessible text-button)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Semantics(
              button: true,
              label: l10n.changeLanguage,
              child: TextButton.icon(
                onPressed: () {
                  localeNotifier.toggleLocale();
                },
                icon: const Icon(Icons.translate, color: Colors.white),
                label: Text(
                  localeNotifier.locale.languageCode == 'en' ? 'RW' : 'EN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dual status banner: Shows active language and togglable connection simulation
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: marketProvider.isOfflineMode 
                      ? const Color(0xFFFFECE0) // Warning Orange-Light
                      : const Color(0xFFE8F5E9), // Success Green-Light
                  border: Border.all(
                    color: marketProvider.isOfflineMode 
                        ? const Color(0xFFE65100) 
                        : const Color(0xFF2E7D32), 
                    width: 2.0
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    // Row 1: Language Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Language / Ururimi:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          localeNotifier.locale.languageCode == 'en'
                              ? 'English (EN)'
                              : 'Ikinyarwanda (RW)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: Colors.black26),
                    // Row 2: Offline/Online Simulator Toggler
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              marketProvider.isOfflineMode ? Icons.wifi_off : Icons.wifi,
                              color: marketProvider.isOfflineMode 
                                  ? const Color(0xFFE65100) 
                                  : const Color(0xFF2E7D32),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Mock Sync Server:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              marketProvider.isOfflineMode 
                                  ? 'Offline (Hive)' 
                                  : 'Online (API Sync)',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: marketProvider.isOfflineMode 
                                    ? const Color(0xFFD32F2F) 
                                    : const Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Simple high contrast toggle button
                            Semantics(
                              button: true,
                              label: 'Toggle Network Status',
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                  side: const BorderSide(color: Colors.black, width: 1.5),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                ),
                                onPressed: () {
                                  marketProvider.toggleMockConnectivity();
                                  // Trigger training articles provider sync or refresh as well
                                  context.read<TrainingKnowledgeProvider>().fetchArticles();
                                },
                                child: const Text(
                                  'TOGGLE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
