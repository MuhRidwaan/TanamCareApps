import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _client = ApiClient();
  final _storage = const FlutterSecureStorage();

  // --- HELPER UNTUK AMBIL PESAN ERROR SPESIFIK DARI LARAVEL ---
  String _getErrorMessage(DioException e) {
    String errorMessage = "Terjadi kesalahan sistem/jaringan.";

    if (e.response != null && e.response!.data != null) {
      final responseData = e.response!.data;

      // Coba ambil dari key 'message' (untuk error umum seperti 401, 500)
      if (responseData is Map && responseData.containsKey('message')) {
        errorMessage = responseData['message'];
      }

      // Coba ambil dari key 'errors' (untuk error validasi 422)
      if (responseData is Map && responseData.containsKey('errors')) {
        final errors = responseData['errors'];
        if (errors is Map && errors.isNotEmpty) {
          // Ambil pesan error pertama dari field manapun
          errorMessage = errors.values.first is List
              ? errors.values.first.first
              : errors.values.first.toString();
        }
      }
    }
    return errorMessage;
  }

  // --- LOGIN ---
  Future<bool> login(String email, String password) async {
    // ... kode login tetap sama ...
    try {
      final response = await _client.dio.post(
        Endpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final token = response.data['access_token'];
      await _storage.write(key: 'access_token', value: token);

      return true;
    } on DioException catch (e) {
      // Tidak perlu throw di sini jika logic loginmu hanya butuh true/false
      return false;
    }
  }

  // --- REGISTER ---
  Future<bool> register(String name, String email, String password) async {
    try {
      await _client.dio.post(
        Endpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      return true;
    } on DioException catch (e) {
      // Panggil helper untuk mengambil pesan error yang aman
      throw Exception(_getErrorMessage(e));
    }
  }

  // --- GET PROFILE ---
  Future<UserModel?> getUserProfile() async {
    // ... kode tetap sama ...
    try {
      final response = await _client.dio.get(Endpoints.user);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      print("Get User Error: ${e.response?.data}");
      return null;
    }
  }

  // --- UPDATE PROFILE (DIPERBAIKI) ---
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? password,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (password != null && password.isNotEmpty) data['password'] = password;

      final response = await _client.dio.put(
        Endpoints.updateProfile,
        data: data,
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      // Panggil helper untuk mengambil pesan error yang aman
      throw Exception(_getErrorMessage(e));
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    // ... kode tetap sama ...
    try {
      await _client.dio.post(Endpoints.logout);
      await _storage.delete(key: 'access_token');
    } catch (e) {
      print("Logout error: $e");
    }
  }
}
