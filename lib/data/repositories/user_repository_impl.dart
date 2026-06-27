import 'package:agriyouthconnect/core/network/api_client.dart';
import 'package:agriyouthconnect/data/datasources/hive_cache_service.dart';
import 'package:agriyouthconnect/data/datasources/mock_api_provider.dart';
import 'package:agriyouthconnect/data/models/user_profile_model.dart';
import 'package:agriyouthconnect/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiClient? _apiClient;

  UserRepositoryImpl({ApiClient? apiClient}) : _apiClient = apiClient;

  @override
  Future<UserProfileModel?> getUserProfile() async {
    final box = HiveCacheService.userProfileBox;
    if (box.containsKey('active_profile')) {
      return box.get('active_profile');
    }
    return null;
  }

  @override
  Future<bool> saveUserProfile(UserProfileModel profile) async {
    // 1. Always cache profile locally first (Offline-First compliance)
    final profileBox = HiveCacheService.userProfileBox;
    final settingsBox = HiveCacheService.syncSettingsBox;
    
    await profileBox.put('active_profile', profile);
    await settingsBox.put('is_profile_synced', false); // Mark as unsynced in config settings box

    // 2. Attempt synchronizing with Node.js server immediately
    if (_apiClient != null) {
      try {
        final response = await _apiClient.post('/auth/register', data: profile.toJson());
        if (response.statusCode == 200 || response.statusCode == 201) {
          await settingsBox.put('is_profile_synced', true); // Synced successfully!
        }
      } catch (_) {
        // Fail silently so the app remains fully operational offline
      }
    } else {
      // Backward-compatible fallback simulation for unit tests using MockApiProvider
      if (MockApiProvider.isOnline) {
        try {
          await MockApiProvider.registerUserProfile(profile);
          await settingsBox.put('is_profile_synced', true);
        } catch (_) {}
      }
    }
    return true;
  }

  @override
  Future<void> clearUserProfile() async {
    await HiveCacheService.userProfileBox.delete('active_profile');
    await HiveCacheService.syncSettingsBox.delete('is_profile_synced');
  }
}
