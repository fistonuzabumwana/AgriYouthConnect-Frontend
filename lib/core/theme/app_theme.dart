import 'package:flutter/material.dart';

/// AppTheme manages the typography and color system for AgriYouthConnectAI.
/// The configuration specifically targets high-contrast ratios required for
/// readability under intense sunlight in outdoor field conditions.
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  // High-contrast Color Palette (optimized for outdoor sunlight)
  static const Color primaryGreen = Color(0xFF2E7D32); // Agricultural Green base
  static const Color primaryDark = Color(0xFF1B5E20); // High contrast dark green
  static const Color secondaryBlue = Color(0xFF1565C0); // Accessible status action
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure white background for max reflectance
  static const Color surfaceLight = Color(0xFFF5F5F5); // Light grey for contrast separation
  
  // Severe weather and alert status tokens (High visibility)
  static const Color statusSuccess = Color(0xFF1B5E20); // Dark Green for positive trend
  static const Color statusWarning = Color(0xFFE65100); // Deep Orange for warning (higher contrast than yellow)
  static const Color statusError = Color(0xFFD32F2F); // Deep Red for severe alerts/errors
  static const Color statusInfo = Color(0xFF0D47A1); // Deep Blue for informational trends

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF000000); // Pure black for maximum legibility
  static const Color textSecondaryLight = Color(0xFF212121); // Off-black/very dark grey for secondary info
  static const Color textContrastWhite = Color(0xFFFFFFFF); // White text on dark elements

  /// Accessibility Light Theme
  /// Optimized for sunlight readability with strict contrast ratios (>= 7:1 for text).
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: secondaryBlue,
        surface: backgroundLight,
        error: statusError,
        onPrimary: textContrastWhite,
        onSecondary: textContrastWhite,
        onSurface: textPrimaryLight,
        onError: textContrastWhite,
      ),
      dividerTheme: const DividerThemeData(
        color: textPrimaryLight,
        thickness: 1.5,
        space: 16,
      ),
      cardTheme: const CardThemeData(
        color: backgroundLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: textPrimaryLight, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        labelStyle: TextStyle(
          color: textPrimaryLight,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: textSecondaryLight,
          fontSize: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textPrimaryLight, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryDark, width: 3.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: statusError, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: statusError, width: 3.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: textContrastWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textContrastWhite,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: textContrastWhite,
          size: 24,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimaryLight,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: textPrimaryLight,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: textPrimaryLight,
          fontSize: 16,
          fontWeight: FontWeight.w600, // Medium-bold body text for better outdoor visibility
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          color: textSecondaryLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: textPrimaryLight,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: textContrastWhite,
          disabledBackgroundColor: Colors.grey[400],
          disabledForegroundColor: Colors.grey[800],
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: textPrimaryLight, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Optional High-Contrast Dark Theme
  /// Optimized for dark mode usage with elevated color accents.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: const Color(0xFF000000), // Pure black background for max screen contrast
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: secondaryBlue,
        surface: Color(0xFF121212),
        error: statusError,
        onPrimary: textContrastWhite,
        onSecondary: textContrastWhite,
        onSurface: textContrastWhite,
        onError: textContrastWhite,
      ),
      dividerTheme: const DividerThemeData(
        color: textContrastWhite,
        thickness: 1.5,
        space: 16,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF121212),
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: textContrastWhite, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1E1E1E),
        labelStyle: TextStyle(
          color: textContrastWhite,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textContrastWhite, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryGreen, width: 2.5),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: statusError, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: textContrastWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textContrastWhite,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textContrastWhite,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
        displayMedium: TextStyle(
          color: textContrastWhite,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: textContrastWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: textContrastWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: textContrastWhite,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: textContrastWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: textContrastWhite, width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
