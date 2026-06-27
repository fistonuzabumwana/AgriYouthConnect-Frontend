import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// AppLocalizations handles compile-time safe, custom translation mappings
/// for AgriYouthConnectAI between English ('en') and Kinyarwanda ('rw').
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Actions
      'save': 'Save',
      'cancel': 'Cancel',
      'next': 'Next',
      'back': 'Back',
      'search': 'Search',
      'submit': 'Submit',
      'change_language': 'Hindura Ururimi (Kinyarwanda)',
      
      // Registration Profile Form
      'registration_title': 'Farmer Registration',
      'registration_subtitle': 'Complete your profile to get real-time market insights and AI recommendations.',
      'name': 'Full Name',
      'name_hint': 'Enter your full name',
      'location': 'Location (District & Sector)',
      'district': 'District',
      'district_hint': 'Select District',
      'sector': 'Sector',
      'sector_hint': 'Select Sector',
      'crop_type': 'Primary Crop Type',
      'farm_size': 'Farm Size (Hectares)',
      'farm_size_hint': 'e.g., 0.5',
      'experience_level': 'Farming Experience Level',
      'select_experience': 'Select Experience Level',
      
      // Crops
      'maize': 'Maize (Ibigori)',
      'beans': 'Beans (Ibihyimbo)',
      'coffee': 'Coffee (Ikawa)',
      'irish_potatoes': 'Irish Potatoes (Ibirayi)',

      // Experience levels
      'experience_beginner': 'Beginner (1-2 years)',
      'experience_intermediate': 'Intermediate (3-5 years)',
      'experience_expert': 'Expert (5+ years)',

      // Core Module Navigation / Content
      'market_prices': 'Market Prices',
      'knowledge_hub': 'Knowledge Hub',
      'ai_advisory': 'AI Advisory',
      'networking': 'Networking',

      // Market Prices Screen
      'market_title': 'Real-Time Market Board',
      'market_subtitle': 'Live wholesale commodity prices across Rwanda districts',
      'price_per_kg': 'Price per kg',
      'trend': 'Trend',
      'trend_rising': 'Price Up',
      'trend_falling': 'Price Down',
      'trend_stable': 'Stable',
      'last_updated': 'Last updated',

      // Training Screen
      'training_title': 'Agricultural Knowledge Hub',
      'training_subtitle': 'Offline-ready farming guides and tutorials',
      'search_guides': 'Search training guides...',
      'read_article': 'Read Guide',
      'offline_ready': 'Available Offline',
      'crop_category': 'Crop',
      'duration': 'Est. read time',
      'mins': 'mins',

      // Validation
      'field_required': 'This field is required',
      'invalid_number': 'Please enter a valid number',
      'success_registered': 'Profile registered successfully!',
    },
    'rw': {
      // Actions
      'save': 'Emeza',
      'cancel': 'Kureha',
      'next': 'Komeza',
      'back': 'Gusubira inyuma',
      'search': 'Shakisha',
      'submit': 'Kohereza',
      'change_language': 'Change Language (English)',

      // Registration Profile Form
      'registration_title': 'Kwandika Umuhinzi',
      'registration_subtitle': 'Uzuza umwirondoro wawe kugira ngo ubone ibiciro byo ku isoko n\'inama za AI.',
      'name': 'Izina Ryose',
      'name_hint': 'Andika amazina yawe yose',
      'location': 'Aho uherereye (Akarere & Umurenge)',
      'district': 'Akarere',
      'district_hint': 'Hitamo Akarere',
      'sector': 'Umurenge',
      'sector_hint': 'Hitamo Umurenge',
      'crop_type': 'Igihingwa Ngandorarwanda',
      'farm_size': 'Ingano y\'Umurima (Ha)',
      'farm_size_hint': 'Urugero: 0.5',
      'experience_level': 'Uburambe mu Buhinzi',
      'select_experience': 'Hitamo Uburambe',

      // Crops
      'maize': 'Ibigori',
      'beans': 'Ibihyimbo',
      'coffee': 'Ikawa',
      'irish_potatoes': 'Ibirayi',

      // Experience levels
      'experience_beginner': 'Ugitangira (Imyaka 1-2)',
      'experience_intermediate': 'Ugereranyije (Imyaka 3-5)',
      'experience_expert': 'Inararibonye (Imyaka 5+)',

      // Core Module Navigation / Content
      'market_prices': 'Ibiciro ku Isoko',
      'knowledge_hub': 'Ubumenyi n\'Amahugurwa',
      'ai_advisory': 'Inama za AI',
      'networking': 'Gushyikirana',

      // Market Prices Screen
      'market_title': 'Ibiciro ku Masoko',
      'market_subtitle': 'Ibiciro ntarengwa by\'imyaka mu Turere tw\'u Rwanda',
      'price_per_kg': 'Ikiguzi ku kilo',
      'trend': 'Imihindukire',
      'trend_rising': 'Kuzamuka',
      'trend_falling': 'Kugabanuka',
      'trend_stable': 'Bihamye',
      'last_updated': 'Byavuguruwe',

      // Training Screen
      'training_title': 'Ubumenyi n\'Amahugurwa',
      'training_subtitle': 'Imfashanyigisho zo guhinga zikora no mufoni idafite interineti',
      'search_guides': 'Shakisha imfashanyigisho...',
      'read_article': 'Soma Imfashanyigisho',
      'offline_ready': 'Ibikwa muri Foni',
      'crop_category': 'Igihingwa',
      'duration': 'Igihe bitwara',
      'mins': 'imin',

      // Validation
      'field_required': 'Iyi ntabwo ikwiriye gusigara yera',
      'invalid_number': 'Andika umubare ukwiriye',
      'success_registered': 'Umwirondoro wawe wamaze kwemezwa!',
    }
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Strong-typed getters
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get next => translate('next');
  String get back => translate('back');
  String get search => translate('search');
  String get submit => translate('submit');
  String get changeLanguage => translate('change_language');
  String get registrationTitle => translate('registration_title');
  String get registrationSubtitle => translate('registration_subtitle');
  String get name => translate('name');
  String get nameHint => translate('name_hint');
  String get location => translate('location');
  String get district => translate('district');
  String get districtHint => translate('district_hint');
  String get sector => translate('sector');
  String get sectorHint => translate('sector_hint');
  String get cropType => translate('crop_type');
  String get farmSize => translate('farm_size');
  String get farmSizeHint => translate('farm_size_hint');
  String get experienceLevel => translate('experience_level');
  String get selectExperience => translate('select_experience');
  
  String get maize => translate('maize');
  String get beans => translate('beans');
  String get coffee => translate('coffee');
  String get irishPotatoes => translate('irish_potatoes');
  
  String get experienceBeginner => translate('experience_beginner');
  String get experienceIntermediate => translate('experience_intermediate');
  String get experienceExpert => translate('experience_expert');

  String get marketPrices => translate('market_prices');
  String get knowledgeHub => translate('knowledge_hub');
  String get aiAdvisory => translate('ai_advisory');
  String get networking => translate('networking');

  String get marketTitle => translate('market_title');
  String get marketSubtitle => translate('market_subtitle');
  String get pricePerKg => translate('price_per_kg');
  String get trend => translate('trend');
  String get trendRising => translate('trend_rising');
  String get trendFalling => translate('trend_falling');
  String get trendStable => translate('trend_stable');
  String get lastUpdated => translate('last_updated');

  String get trainingTitle => translate('training_title');
  String get trainingSubtitle => translate('training_subtitle');
  String get searchGuides => translate('search_guides');
  String get readArticle => translate('read_article');
  String get offlineReady => translate('offline_ready');
  String get cropCategory => translate('crop_category');
  String get duration => translate('duration');
  String get mins => translate('mins');

  String get fieldRequired => translate('field_required');
  String get invalidNumber => translate('invalid_number');
  String get successRegistered => translate('success_registered');
}

/// AppLocalizationsDelegate bridges our custom AppLocalizations class
/// with Flutter's standard localization framework.
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'rw'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// LocaleNotifier provides state management for active localizations.
/// It uses ValueNotifier so standard widgets react instantly to changes.
class LocaleNotifier extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }

  void toggleLocale() {
    if (_locale.languageCode == 'en') {
      setLocale(const Locale('rw'));
    } else {
      setLocale(const Locale('en'));
    }
  }
}

/// LocaleProvider is an InheritedNotifier that exposes the LocaleNotifier
/// to the widget tree, automatically triggering rebuilds on changes.
class LocaleProvider extends InheritedNotifier<LocaleNotifier> {
  const LocaleProvider({
    super.key,
    required super.notifier,
    required super.child,
  });

  static LocaleNotifier of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleProvider>()!.notifier!;
  }
}

/// Fallback Material Localizations Delegate for Kinyarwanda ('rw')
/// delegating system strings to English.
class RwMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const RwMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return GlobalMaterialLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(RwMaterialLocalizationsDelegate old) => false;
}

/// Fallback Cupertino Localizations Delegate for Kinyarwanda ('rw')
/// delegating system strings to English.
class RwCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const RwCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return GlobalCupertinoLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(RwCupertinoLocalizationsDelegate old) => false;
}
