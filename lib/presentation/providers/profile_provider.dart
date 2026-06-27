import 'package:flutter/material.dart';
import 'package:agriyouthconnect/data/models/user_profile_model.dart';
import 'package:agriyouthconnect/domain/repositories/user_repository.dart';

/// ProfileProvider manages the loading, caching, and editing states of the farmer profile.
class ProfileProvider extends ChangeNotifier {
  final UserRepository userRepository;

  UserProfileModel? _profile;
  bool _isLoading = false;
  String _errorMessage = '';

  ProfileProvider({required this.userRepository}) {
    fetchProfile();
  }

  UserProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isRegistered => _profile != null;

  /// Loads the profile from the cached repository.
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _profile = await userRepository.getUserProfile();
    } catch (e) {
      _errorMessage = 'Failed to load profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates and persists the farmer's registration profile.
  Future<bool> saveProfile(UserProfileModel newProfile) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final success = await userRepository.saveUserProfile(newProfile);
      if (success) {
        _profile = newProfile;
        return true;
      } else {
        _errorMessage = 'Failed to save profile';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error saving profile: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the profile cache.
  Future<void> clearProfile() async {
    _isLoading = true;
    notifyListeners();

    await userRepository.clearUserProfile();
    _profile = null;
    
    _isLoading = false;
    notifyListeners();
  }
}
