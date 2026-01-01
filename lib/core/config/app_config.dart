class AppConfig {
  // ✅ KITA PAKAI URL DARI VERSI LAMA KAMU (YANG SUDAH BENAR)
  static const String apiBaseUrl =
      "http://tanamcare.myproject.diskon.com/public/index.php/api";

  // Timeout dalam detik (sesuai kodingan ApiClient yang baru)
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
}
