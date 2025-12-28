import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../utils/app_logger.dart';

/// HTTP Client singleton dengan Dio
/// 
/// Penggunaan:
/// ```dart
/// final client = ApiClient();
/// final response = await client.dio.get('/endpoint');
/// ```
class ApiClient {
  // Singleton instance
  static ApiClient? _instance;
  static Dio? _dio;
  static const _storage = FlutterSecureStorage();

  /// Factory constructor untuk singleton
  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(seconds: AppConfig.connectTimeout),
      receiveTimeout: Duration(seconds: AppConfig.receiveTimeout),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // Interceptor untuk Token & Logging
    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Log request
        AppLogger.apiRequest(
          options.method,
          '${options.baseUrl}${options.path}',
          options.data,
        );
        
        // Tambah token ke header
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response
        AppLogger.apiResponse(
          response.requestOptions.path,
          response.statusCode,
        );
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // Log error dengan detail lebih lengkap
        String errorDetail;
        if (e.response != null) {
          errorDetail = 'Status: ${e.response?.statusCode}, Data: ${e.response?.data}';
        } else {
          // Tidak ada response - kemungkinan network error atau CORS
          errorDetail = 'Type: ${e.type.name}, Message: ${e.message}';
          if (e.type == DioExceptionType.connectionError) {
            AppLogger.warning('Connection Error - Periksa koneksi internet atau server tidak dapat dijangkau');
          } else if (e.type == DioExceptionType.unknown) {
            AppLogger.warning('Unknown Error - Kemungkinan CORS issue (jika di Web) atau server tidak merespons');
          }
        }
        AppLogger.error('API Error: ${e.requestOptions.path}', errorDetail);
        
        // Handle 401 Unauthorized - bisa tambah auto logout di sini
        if (e.response?.statusCode == 401) {
          AppLogger.warning('Token expired or invalid');
          // TODO: Implement auto logout atau refresh token
        }
        
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio!;

  /// Reset singleton (untuk testing atau logout)
  static void reset() {
    _dio = null;
    _instance = null;
  }

  /// Get current token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  /// Clear token (untuk logout)
  static Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
  }
}
