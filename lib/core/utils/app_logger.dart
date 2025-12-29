import 'dart:developer' as dev;

class AppLogger {
  // Fungsi dasar
  static void debug(String message) {
    dev.log('🐛 DEBUG: $message');
  }

  static void info(String message) {
    dev.log('ℹ️ INFO: $message');
  }

  static void error(String message, [String? error]) {
    dev.log('❌ ERROR: $message ${error ?? ""}');
  }

  static void warning(String message) {
    dev.log('⚠️ WARNING: $message');
  }

  // --- Fungsi Khusus API (Sesuai permintaan ApiClient baru) ---

  // Menerima 3 parameter: method, url, dan data
  static void apiRequest(String method, String url, dynamic data) {
    dev.log('🌐 REQUEST [$method]: $url');
    if (data != null) {
      dev.log('📦 DATA: $data');
    }
  }

  // Menerima 2 parameter: url dan statusCode
  static void apiResponse(String url, int? statusCode) {
    dev.log('✅ RESPONSE [$statusCode]: $url');
  }
}
