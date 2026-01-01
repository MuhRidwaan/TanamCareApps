import 'package:flutter/material.dart';

/// Warna-warna utama aplikasi TanamCare
///
/// Penggunaan:
/// ```dart
/// Container(color: AppColors.primary)
/// Text('Hello', style: TextStyle(color: AppColors.textPrimary))
/// ```
class AppColors {
  AppColors._();

  // ============ PRIMARY COLORS ============

  /// Hijau utama - digunakan untuk branding
  static const Color primary = Color(0xFF2ECC71);

  /// Hijau sekunder - untuk accent
  static const Color primaryDark = Color(0xFF27AE60);

  /// Hijau gelap - untuk teks utama
  static const Color primaryDarkest = Color(0xFF1B5E20);

  /// Hijau medium - untuk subtitle
  static const Color primaryMedium = Color(0xFF558B2F);

  // ============ BACKGROUND COLORS ============

  /// Background utama aplikasi
  static const Color background = Color(0xFFF5F9F6);

  /// Background card/surface
  static const Color surface = Colors.white;

  /// Background card dengan tint hijau
  static const Color surfaceGreen = Color(0xFFF1F8E9);

  // ============ TEXT COLORS ============

  /// Teks utama (heading)
  static const Color textPrimary = Color(0xFF1B5E20);

  /// Teks sekunder (subtitle)
  static const Color textSecondary = Color(0xFF558B2F);

  /// Teks hint/placeholder
  static const Color textHint = Colors.grey;

  /// Teks di atas primary color
  static const Color textOnPrimary = Colors.white;

  // ============ STATUS COLORS ============

  /// Status sehat/sukses
  static const Color success = Color(0xFF2ECC71);

  /// Status warning
  static const Color warning = Color(0xFFFF9800);

  /// Status error/bahaya
  static const Color error = Color(0xFFF44336);

  /// Status info
  static const Color info = Color(0xFF2196F3);

  // ============ DISEASE SEVERITY COLORS ============

  /// Tanaman sehat
  static const Color healthy = Color(0xFF2ECC71);

  /// Penyakit bakteri
  static const Color bacterial = Color(0xFFFF9800);

  /// Jamur awal
  static const Color fungusEarly = Color(0xFFFF5722);

  /// Jamur lanjut
  static const Color fungusAdvanced = Color(0xFFF44336);

  /// Jamur daun
  static const Color leafFungus = Color(0xFFFFC107);

  // ============ UTILITY COLORS ============

  /// Divider
  static const Color divider = Color(0xFFE0E0E0);

  /// Border
  static const Color border = Color(0xFFC8E6C9);

  /// Shadow
  static const Color shadow = Color(0x1A000000);

  // ============ GRADIENT PRESETS ============

  /// Gradient utama (horizontal)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient untuk card header
  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ============ HELPER METHODS ============

  /// Mendapatkan warna dengan opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Mendapatkan warna status berdasarkan string
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'sehat':
        return healthy;
      case 'warning':
      case 'perlu perhatian':
        return warning;
      case 'error':
      case 'sakit':
        return error;
      default:
        return textSecondary;
    }
  }

  /// Mendapatkan warna untuk diagnosis penyakit
  static Color getDiagnosisColor(String diagnosis) {
    switch (diagnosis) {
      case 'Sehat':
        return healthy;
      case 'Penyakit Bakteri':
        return bacterial;
      case 'Penyakit Jamur Awal':
        return fungusEarly;
      case 'Penyakit Jamur Lanjut':
        return fungusAdvanced;
      case 'Jamur Daun':
        return leafFungus;
      default:
        return textSecondary;
    }
  }
}
