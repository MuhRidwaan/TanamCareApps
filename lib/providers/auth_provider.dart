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

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  /// Load user saat app start (check token & get user data)
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check apakah ada token
      final loggedIn = await _authService.isLoggedIn();
      _isLoggedIn = loggedIn;

      if (loggedIn) {
        // Ambil data user dari API
        final userData = await _authService.getUser();
        if (userData != null) {
          _user = userData;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // =====================
  // REGISTER
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(name, email, password);

    if (result['success'] == true) {
      // Parse user dari response
      if (result['user'] != null) {
        _user = UserModel.fromJson(result['user']);
      } else {
        _user = UserModel(
          id: DateTime.now().millisecondsSinceEpoch,
          name: name,
          email: email,
        );
      }
      _isLoggedIn = true;
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
    return result['success'] == true;
  }

  // =====================
  // LOGIN
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email, password);

    if (result['success'] == true) {
      // Parse user dari response
      if (result['user'] != null) {
        _user = UserModel.fromJson(result['user']);
      } else {
        // Fallback: ambil data user dari API
        final userData = await _authService.getUser();
        _user = userData;
      }
      _isLoggedIn = true;
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
    return result['success'] == true;
  }

  // =====================
  // UPDATE PROFILE
  Future<bool> updateProfile(
    String name,
    String email,
    String? password,
  ) async {
    if (_user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.updateProfile(
      name: name,
      email: email,
      password: password,
    );

    if (result['success'] == true) {
      // Update user data
      if (result['user'] != null) {
        _user = UserModel.fromJson(result['user']);
      } else {
        _user = _user!.copyWith(name: name, email: email);
      }
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
    return result['success'] == true;
  }

  // =====================
  // LOGOUT
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    
    _user = null;
    _isLoggedIn = false;
    _errorMessage = null;

    _isLoading = false;
    notifyListeners();
  }

  // =====================
  // CLEAR ERROR
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
