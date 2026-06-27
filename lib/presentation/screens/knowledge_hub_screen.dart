import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agriyouthconnect/core/localization/app_localizations.dart';
import 'package:agriyouthconnect/core/theme/app_theme.dart';
import 'package:agriyouthconnect/data/models/training_article_model.dart';
import 'package:agriyouthconnect/presentation/providers/training_knowledge_provider.dart';
import 'package:agriyouthconnect/presentation/widgets/custom_button.dart';
import 'package:agriyouthconnect/presentation/widgets/custom_text_field.dart';

/// KnowledgeHubScreen displays modules for Crop Management, Pest Control, and Financial Literacy.
/// Integrated directly with TrainingKnowledgeProvider and local Hive caching.
class KnowledgeHubScreen extends StatefulWidget {
  const KnowledgeHubScreen({super.key});

  @override
  State<KnowledgeHubScreen> createState() => _KnowledgeHubScreenState();
}

class _KnowledgeHubScreenState extends State<KnowledgeHubScreen> {
  final _searchController = TextEditingController();
  String? _selectedModule; // 'Crop Management', 'Pest Control', 'Financial Literacy'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Trigger search filter in the provider
    context.read<TrainingKnowledgeProvider>().fetchArticles(
          query: _searchController.text.trim(),
        );
  }

  List<TrainingArticleModel> _filterArticlesByModule(
      List<TrainingArticleModel> articles, AppLocalizations l10n) {
    if (_selectedModule == null) return articles;

    return articles.where((article) {
      final category = article.cropCategory.toLowerCase();
      final title = article.title.toLowerCase();
      final body = article.body.toLowerCase();

      if (_selectedModule == 'Crop Management') {
        // Crop management covers Maize and Coffee guides
        return category == 'maize' || category == 'coffee' || title.contains('plant') || body.contains('plant') || title.contains('crop') || body.contains('crop');
      } else if (_selectedModule == 'Pest Control') {
        // Pest control covers Beans (stem maggot) and Potato blight
        return category == 'beans' || category == 'irish potatoes' || title.contains('pest') || body.contains('pest') || title.contains('blight') || body.contains('blight');
      } else if (_selectedModule == 'Financial Literacy') {
        // Fallback mockup guides for finance literacy
        return title.contains('finance') || body.contains('finance') || title.contains('cost') || body.contains('cost') || title.contains('budget') || body.contains('budget') || category == 'financial';
      }
      return true;
    }).toList();
  }

  void _showArticleReader(TrainingArticleModel article) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            article.title,
                            style: theme.textTheme.displayMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Chip(
                          label: Text(article.cropCategory),
                          side: const BorderSide(color: Colors.black, width: 1.5),
                        ),
                        const SizedBox(width: 8),
                        if (article.isOfflineAvailable)
                          Chip(
                            avatar: const Icon(Icons.offline_pin, size: 16),
                            label: Text(l10n.offlineReady),
                            backgroundColor: AppTheme.statusSuccess.withValues(alpha: 0.1),
                            side: const BorderSide(color: AppTheme.statusSuccess, width: 1.5),
                            labelStyle: const TextStyle(color: AppTheme.statusSuccess),
                          ),
                      ],
                    ),
                    const Divider(height: 32),
                    Text(
                      article.body,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    CustomButton(
                      label: l10n.back,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trainingProvider = Provider.of<TrainingKnowledgeProvider>(context);

    // Filter list based on selected grid module
    final filteredArticles = _filterArticlesByModule(trainingProvider.articles, l10n);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row with sync trigger
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.trainingTitle,
                      style: theme.textTheme.displayMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.trainingSubtitle,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: 'Sync all articles for offline',
                child: IconButton.filled(
                  icon: const Icon(Icons.cloud_sync, size: 28),
                  onPressed: () async {
                    try {
                      await trainingProvider.syncAllForOffline();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Offline synchronization complete!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sync failed: ${e.toString().replaceAll('Exception:', '').trim()}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: AppTheme.statusError,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Module Selection Grid (Crop Management, Pest Control, Financial Literacy)
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.1,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildModuleCard(
                title: 'Crop Mgmt',
                subtitle: 'Ibihingwa',
                icon: Icons.grass,
                moduleKey: 'Crop Management',
                isSelected: _selectedModule == 'Crop Management',
                theme: theme,
              ),
              _buildModuleCard(
                title: 'Pest Control',
                subtitle: 'Kuvura',
                icon: Icons.bug_report,
                moduleKey: 'Pest Control',
                isSelected: _selectedModule == 'Pest Control',
                theme: theme,
              ),
              _buildModuleCard(
                title: 'Finance',
                subtitle: 'Urwuri',
                icon: Icons.account_balance_wallet,
                moduleKey: 'Financial Literacy',
                isSelected: _selectedModule == 'Financial Literacy',
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Field
          CustomTextField(
            controller: _searchController,
            labelText: l10n.search,
            hintText: l10n.searchGuides,
            prefixIcon: Icons.search,
          ),
          const SizedBox(height: 16),

          // Article List
          Expanded(
            child: trainingProvider.isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 4.0))
                : filteredArticles.isEmpty
                    ? Center(
                        child: Text(
                          'No guides matches your search.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredArticles.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final article = filteredArticles[index];
                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              border: Border.all(
                                color: isDark ? Colors.white : Colors.black,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        article.title,
                                        style: theme.textTheme.titleMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Save Offline Toggle
                                    Semantics(
                                      button: true,
                                      label: article.isOfflineAvailable 
                                          ? 'Downloaded. Tap to remove.' 
                                          : 'Save Offline',
                                      child: IconButton(
                                        icon: Icon(
                                          article.isOfflineAvailable 
                                              ? Icons.offline_pin 
                                              : Icons.offline_pin_outlined,
                                          color: article.isOfflineAvailable 
                                              ? theme.colorScheme.primary 
                                              : Colors.grey,
                                          size: 28,
                                        ),
                                        onPressed: () {
                                          trainingProvider.toggleOfflineSave(article.id);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  article.body,
                                  style: theme.textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${l10n.duration}: ${article.readTimeMins} ${l10n.mins}',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (article.isOfflineAvailable) ...[
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.statusSuccess,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              l10n.locale.languageCode == 'en' ? 'SAVED' : 'BIKWE',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    TextButton.icon(
                                      onPressed: () =>
                                          _showArticleReader(article),
                                      icon: const Icon(Icons.menu_book),
                                      label: Text(l10n.readArticle),
                                      style: TextButton.styleFrom(
                                        foregroundColor: theme.colorScheme.primary,
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String moduleKey,
    required bool isSelected,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedModule == moduleKey) {
            _selectedModule = null; // Toggle off filter
          } else {
            _selectedModule = moduleKey;
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary 
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          border: Border.all(
            color: isDark ? Colors.white : Colors.black,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? Colors.white : theme.colorScheme.primary),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white70 : (isDark ? Colors.grey : Colors.black54),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
