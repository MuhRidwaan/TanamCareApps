import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Import ini penting untuk kIsWeb
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // LOGIC BASE URL:
  // Jika Web (Chrome) -> pakai localhost
  // Jika Android Emulator -> pakai 10.0.2.2
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api'; //
    } else {
      return 'http://10.0.2.2:8000/api';
    }
  }

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json', // Wajib sertakan ini
      },
    ));

    // Interceptor untuk Token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Ambil token dari storage
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          // Format Authorization: Bearer <token> [cite: 15]
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle error seperti 401 Unauthorized disini
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
