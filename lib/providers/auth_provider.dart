import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage; // Getter error

  UserModel? _user;
  UserModel? get user => _user;

  // --- REGISTER (DIPERBAIKI) ---
  Future<bool> register(String name, String email, String password) async {
    _isLoading = false;
    _errorMessage = null; // Reset error lama
    notifyListeners();

    try {
      // Panggil service
      final success = await _authService.register(name, email, password);

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      // Bersihkan teks "Exception: " agar lebih rapi di layar
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  // --- LOGIN ---
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.login(email, password);
      if (success) {
        _user = await _authService.getUserProfile();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Login Gagal";
      notifyListeners();
      return false;
    }
  }

  // --- UPDATE PROFILE FUNCTION ---
  Future<bool> updateProfile(String name, String email, String? password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Panggil update service
      await _authService.updateProfile(
        name: name,
        email: email,
        password: password,
      );

      // JIKA SUKSES KE SERVER, LANGSUNG PANGGIL loadUser() UNTUK SINKRONISASI
      await loadUser(); // loadUser ini akan me-re-fetch data dari GET /user
      
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
}

  // --- LOGOUT ---
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  // --- LOAD USER (CEK TOKEN) ---
  Future<void> loadUser() async {
    _user = await _authService.getUserProfile();
    notifyListeners();
  }
}
