import 'package:agriyouthconnect/data/models/user_profile_model.dart';

/// Abstract contract for managing farmer profile data access.
abstract class UserRepository {
  /// Fetches the currently saved user profile from local cache or remote server.
  Future<UserProfileModel?> getUserProfile();

  /// Saves or updates the farmer's profile.
  Future<bool> saveUserProfile(UserProfileModel profile);

  /// Clears the saved user profile from cache.
  Future<void> clearUserProfile();
}
