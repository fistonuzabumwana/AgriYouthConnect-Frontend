/// AppConfig manages configurable constants dynamically.
class AppConfig {
  AppConfig._();

  /// Retrieve the Node.js API Gateway route from compile-time settings
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api', // Maps to localhost for Android Emulators
  );
}
