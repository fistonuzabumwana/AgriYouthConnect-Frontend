import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:agriyouthconnect/core/network/api_client.dart';
import 'package:agriyouthconnect/data/datasources/hive_cache_service.dart';
import 'package:agriyouthconnect/data/models/user_profile_model.dart';
import 'package:hive/hive.dart';

/// SyncQueueService monitors connectivity states and uploads offline modifications to Node.js backend.
class SyncQueueService {
  final ApiClient _apiClient;
  final Box _syncSettingsBox;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  SyncQueueService({
    required ApiClient apiClient,
    Box? syncSettingsBox,
    Connectivity? connectivity,
  })  : _apiClient = apiClient,
        _syncSettingsBox = syncSettingsBox ?? HiveCacheService.syncSettingsBox,
        _connectivity = connectivity ?? Connectivity();

  /// Start connection monitoring listener
  void start() {
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final hasConnection = results.any((result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet);

      if (hasConnection) {
        triggerBackgroundSync();
      }
    });
  }

  /// Stop connection monitoring listener
  void stop() {
    _subscription?.cancel();
  }

  /// Check dirty flags and upload un-synchronized profile data
  Future<void> triggerBackgroundSync() async {
    final isSynced = _syncSettingsBox.get('is_profile_synced', defaultValue: true) as bool;

    if (!isSynced && HiveCacheService.userProfileBox.containsKey('active_profile')) {
      final profile = HiveCacheService.userProfileBox.get('active_profile');
      if (profile != null) {
        try {
          final response = await _apiClient.post('/auth/register', data: profile.toJson());
          if (response.statusCode == 200 || response.statusCode == 201) {
            await _syncSettingsBox.put('is_profile_synced', true);
            debugPrint('SyncQueue: Profile successfully synchronized with remote server.');
          }
        } catch (_) {
          // Sync failed, leaves flag dirty to retry on next connection state transition
          debugPrint('SyncQueue: Profile sync failed. Will retry.');
        }
      }
    }
  }

  // Simple static debug print wrapper
  static void debugPrint(String message) {
    // Avoid console spam in unit tests
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      print('[Background Sync Queue] $message');
    }
  }
}
