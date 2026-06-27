import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:agriyouthconnect/core/network/api_client.dart';
import 'package:agriyouthconnect/data/datasources/hive_cache_service.dart';
import 'package:agriyouthconnect/data/models/user_profile_model.dart';
import 'package:agriyouthconnect/domain/repositories/sync_repository.dart';
import 'package:hive/hive.dart';

/// SyncRepositoryImpl handles connection monitors and pushes cached profile modifications.
class SyncRepositoryImpl implements SyncRepository {
  final ApiClient _apiClient;
  final Box _syncSettingsBox;
  final Box<UserProfileModel> _userProfileBox;
  final Connectivity _connectivity;

  SyncRepositoryImpl({
    required ApiClient apiClient,
    Box? syncSettingsBox,
    Box<UserProfileModel>? userProfileBox,
    Connectivity? connectivity,
  })  : _apiClient = apiClient,
        _syncSettingsBox = syncSettingsBox ?? HiveCacheService.syncSettingsBox,
        _userProfileBox = userProfileBox ?? HiveCacheService.userProfileBox,
        _connectivity = connectivity ?? Connectivity();

  @override
  Future<void> triggerOfflineSync() async {
    // 1. Fetch active data states via connectivity service
    final results = await _connectivity.checkConnectivity();
    final hasConnection = results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);

    if (!hasConnection) {
      return;
    }

    // 2. Fetch the user profile update queue states in the local settings box
    final isSynced = _syncSettingsBox.get('is_profile_synced', defaultValue: true) as bool;

    // 3. Iterate through queue to push local changes to Node.js Gateway
    if (!isSynced && _userProfileBox.containsKey('active_profile')) {
      final profile = _userProfileBox.get('active_profile');
      if (profile != null) {
        try {
          final response = await _apiClient.patch(
            '/users/profile',
            data: profile.toJson(),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Purge from local sync queue cache by marking it as clean
            await _syncSettingsBox.put('is_profile_synced', true);
            print('[Sync Repository] Sync Success: Farmer profile synchronized with Node.js backend.');
          }
        } catch (e) {
          print('[Sync Repository] Sync Warning: Profile push failed. Retrying later. Error: $e');
        }
      }
    }
  }
}
