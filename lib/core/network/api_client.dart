import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:agriyouthconnect/core/config/app_config.dart';
import 'package:agriyouthconnect/core/errors/exceptions.dart';
import 'package:agriyouthconnect/data/datasources/local/secure_storage_service.dart';

/// ApiClient abstracts network operations and intercepts HTTP states dynamically.
class ApiClient {
  late final Dio _dio;
  final SecureStorageService _secureStorageService;

  ApiClient({
    Dio? dio,
    required SecureStorageService secureStorageService,
  }) : _secureStorageService = secureStorageService {
    _dio = dio ?? Dio();
    
    // Set connection idle timeout to zero to prevent background socket handlers from hanging tests
    if (_dio.httpClientAdapter is IOHttpClientAdapter) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.idleTimeout = Duration.zero;
        return client;
      };
    }
    
    // Configure standard timeouts optimized for rural environments
    _dio.options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    // Dynamic headers and token injection interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorageService.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException err, handler) {
          // Map backend response codes directly to custom application exceptions
          final mappedException = _mapDioException(err);
          
          return handler.next(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: err.type,
              error: mappedException,
              message: mappedException.toString(),
            ),
          );
        },
      ),
    );
  }

  /// Shut down connection pools, releasing resources immediately (needed for test isolation)
  void close() {
    _dio.close(force: true);
  }

  /// Perform standard HTTP GET wraps
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Perform standard HTTP POST wraps
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Perform standard HTTP PATCH wraps
  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException err) {
    if (err.error is Exception) {
      return err.error as Exception;
    }
    return _mapDioException(err);
  }

  Exception _mapDioException(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return const NetworkException(
        message: 'Network timed out. Connection is unstable.',
      );
    }

    final response = err.response;
    if (response != null) {
      final code = response.statusCode;
      if (code == 401 || code == 403) {
        return const AuthException(
          message: 'Invalid credentials or login session expired.',
        );
      }
      if (code != null && code >= 500) {
        return const ServerException(
          message: 'Live node server error occurred. Try again later.',
        );
      }
    }

    return NetworkException(
      message: err.message ?? 'A general connection error occurred.',
    );
  }
}
