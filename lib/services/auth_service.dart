class AuthService {
  Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    // Simulasi API
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> login(
    String email,
    String password,
  ) async {
    // Simulasi API
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
