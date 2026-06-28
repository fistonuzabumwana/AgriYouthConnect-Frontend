import 'package:flutter/material.dart';
import 'package:agriyouthconnect/core/errors/exceptions.dart';
import 'package:agriyouthconnect/core/network/api_client.dart';
import 'package:agriyouthconnect/data/datasources/hive_cache_service.dart';
import 'package:agriyouthconnect/data/datasources/local/secure_storage_service.dart';
import 'package:agriyouthconnect/data/models/user_profile_model.dart';
import 'package:hive/hive.dart';

/// AuthProvider manages user authentication sessions, JWT tokens, and profiles.
class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorageService;
  final Box<UserProfileModel> _profileBox;

  bool _isAuthenticated = false;
  String? _authToken;
  UserProfileModel? _activeProfile;
  bool _isLoading = false;
  String _errorMessage = '';

  AuthProvider({
    required ApiClient apiClient,
    required SecureStorageService secureStorageService,
    Box<UserProfileModel>? profileBox,
  })  : _apiClient = apiClient,
        _secureStorageService = secureStorageService,
        _profileBox = profileBox ?? Hive.box<UserProfileModel>(HiveCacheService.userProfileBoxName) {
    checkAuthStatus();
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get authToken => _authToken;
  UserProfileModel? get activeProfile => _activeProfile;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  ApiClient get apiClient => _apiClient;

  /// Check secure storage on boot to auto-restore active JWT sessions
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _secureStorageService.readToken();
      if (token != null && _profileBox.containsKey('active_profile')) {
        _authToken = token;
        _activeProfile = _profileBox.get('active_profile');
        _isAuthenticated = true;
      }
    } catch (_) {
      _errorMessage = 'Failed to check authentication status.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login a farmer using phone number and password credentials
  Future<bool> loginFarmer(String phone, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiClient.post('/auth/login', data: {
        'phone': phone,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;
        final profileJson = data['profile'] as Map<String, dynamic>;
        final profile = UserProfileModel.fromJson(profileJson);

        await _secureStorageService.writeToken(token);
        await _profileBox.put('active_profile', profile);

        _authToken = token;
        _activeProfile = profile;
        _isAuthenticated = true;
        return true;
      }
      _errorMessage = 'Login failed. Invalid server response.';
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during login.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new farmer profile dynamically
  Future<bool> registerFarmer(UserProfileModel profile) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiClient.post('/auth/register', data: profile.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;
        final registeredProfileJson = data['profile'] as Map<String, dynamic>;
        final registeredProfile = UserProfileModel.fromJson(registeredProfileJson);

        await _secureStorageService.writeToken(token);
        await _profileBox.put('active_profile', registeredProfile);

        _authToken = token;
        _activeProfile = registeredProfile;
        _isAuthenticated = true;
        return true;
      }
      _errorMessage = 'Registration failed. Invalid server response.';
      return false;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during registration.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Terminate session and clear credentials
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _secureStorageService.deleteToken();
      await _profileBox.delete('active_profile');
    } catch (_) {}

    _authToken = null;
    _activeProfile = null;
    _isAuthenticated = false;
    _isLoading = false;
    notifyListeners();
  }
}
