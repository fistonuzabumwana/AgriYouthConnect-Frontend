import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agriyouthconnect/core/localization/app_localizations.dart';
import 'package:agriyouthconnect/core/theme/app_theme.dart';
import 'package:agriyouthconnect/data/models/market_price_model.dart';
import 'package:agriyouthconnect/presentation/providers/market_price_provider.dart';
import 'package:agriyouthconnect/presentation/widgets/custom_text_field.dart';

/// MarketBoardScreen renders the live market prices board.
/// Consumes MarketPriceProvider and supports district searches and crop category chips.
class MarketBoardScreen extends StatefulWidget {
  const MarketBoardScreen({super.key});

  @override
  State<MarketBoardScreen> createState() => _MarketBoardScreenState();
}

class _MarketBoardScreenState extends State<MarketBoardScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory; // 'Maize', 'Beans', 'Coffee', 'Irish Potatoes'

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
    context.read<MarketPriceProvider>().fetchPrices(
          district: _searchController.text.trim(),
        );
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'rising':
        return AppTheme.statusSuccess; // Dark Green
      case 'falling':
        return AppTheme.statusError; // Deep Red
      default:
        return AppTheme.statusWarning; // Deep Orange
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'rising':
        return Icons.arrow_upward;
      case 'falling':
        return Icons.arrow_downward;
      default:
        return Icons.trending_flat;
    }
  }

  Widget _buildTrendIndicator(MarketPriceModel item, AppLocalizations l10n) {
    final diff = item.pricePerKg - item.previousPrice;
    final color = _getTrendColor(item.trend);
    final icon = _getTrendIcon(item.trend);

    String text = '';
    if (diff > 0) {
      text = '+${diff.toStringAsFixed(0)} RWF';
    } else if (diff < 0) {
      text = '${diff.toStringAsFixed(0)} RWF';
    } else {
      text = l10n.locale.languageCode == 'en' ? 'Stable' : 'Bihamye';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 2.0),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final marketProvider = Provider.of<MarketPriceProvider>(context);

    // Filter list based on both district search and category chip selection
    final filteredPrices = marketProvider.prices.where((item) {
      if (_selectedCategory == null) return true;
      return item.cropName.toLowerCase() == _selectedCategory!.toLowerCase();
    }).toList();

    final categories = [
      {'value': null, 'label': 'All Crops'},
      {'value': 'Maize', 'label': l10n.maize},
      {'value': 'Beans', 'label': l10n.beans},
      {'value': 'Coffee', 'label': l10n.coffee},
      {'value': 'Irish Potatoes', 'label': l10n.irishPotatoes},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.marketTitle,
            style: theme.textTheme.displayMedium,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.marketSubtitle,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // District Filter Input
          CustomTextField(
            controller: _searchController,
            labelText: l10n.search,
            hintText: 'Enter District (e.g. Musanze, Rubavu)',
            prefixIcon: Icons.search,
          ),
          const SizedBox(height: 12),

          // Flanking Crop Category Choice Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      cat['label']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primary,
                    backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark ? Colors.white30 : Colors.black),
                      width: 2.0,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? cat['value'] : null;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Pricing Cards Grid/List
          Expanded(
            child: marketProvider.isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 4.0))
                : marketProvider.errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          marketProvider.errorMessage,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : filteredPrices.isEmpty
                        ? const Center(
                            child: Text(
                              'No market data found.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => marketProvider.refreshPrices(),
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: filteredPrices.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = filteredPrices[index];

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
                                          Text(
                                            item.cropName == 'Maize'
                                                ? l10n.maize
                                                : item.cropName == 'Beans'
                                                    ? l10n.beans
                                                    : item.cropName == 'Coffee'
                                                        ? l10n.coffee
                                                        : l10n.irishPotatoes,
                                            style: theme.textTheme.titleMedium,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: isDark ? Colors.white54 : Colors.black54,
                                                width: 1.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                            child: Text(
                                              item.district,
                                              style: theme.textTheme.labelLarge,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.pricePerKg,
                                                style: theme.textTheme.bodyMedium,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${item.pricePerKg.toStringAsFixed(0)} RWF',
                                                style: theme.textTheme.titleLarge?.copyWith(
                                                  color: theme.colorScheme.primary,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                          _buildTrendIndicator(item, l10n),
                                        ],
                                      ),
                                      const Divider(height: 24),
                                      Text(
                                        '${item.marketName} • ${l10n.lastUpdated}: ${item.lastUpdated.hour}:${item.lastUpdated.minute.toString().padLeft(2, '0')}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
