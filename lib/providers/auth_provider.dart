import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _user;
  UserModel? get user => _user;

<<<<<<< Updated upstream
  void loadUser() {
=======
  // --- REGISTER (DIPERBAIKI) ---
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;  // Fixed: was false
    _errorMessage = null; // Reset error lama
>>>>>>> Stashed changes
    notifyListeners();
  }

  // =====================
  // REGISTER
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _authService.register(name, email, password);

    if (success) {
      _user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        email: email,
      );
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  // =====================
  // LOGIN
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _authService.login(email, password);

    if (success) {
      _user = UserModel(
        id: 1,
        name: "User",
        email: email,
      );
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  // =====================
  // UPDATE PROFILE (COCOK DENGAN EditProfileScreen)
  Future<bool> updateProfile(
    String name,
    String email,
    String? password,
  ) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // password belum dipakai (opsional, future)
      _user = _user!.copyWith(
        name: name,
        email: email,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =====================
  // LOGOUT
  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }
}
