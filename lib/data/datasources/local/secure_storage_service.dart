import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SecureStorageService isolates user session tokens inside the platform secure enclave.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token_jwt';

  /// Write JWT token to secure storage
  Future<void> writeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Read JWT token from secure storage
  Future<String?> readToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Remove JWT token from secure storage
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
