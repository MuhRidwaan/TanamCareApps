import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguageProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String _currentLanguage = 'id'; // 'id' for Indonesian, 'en' for English

  String get currentLanguage => _currentLanguage;
  bool get isEnglish => _currentLanguage == 'en';
  bool get isIndonesian => _currentLanguage == 'id';

  // Load saved language preference
  Future<void> loadLanguage() async {
    try {
      final savedLanguage = await _storage.read(key: 'app_language');
      if (savedLanguage != null) {
        _currentLanguage = savedLanguage;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading language: $e');
    }
  }

  // Change language
  Future<void> setLanguage(String languageCode) async {
    try {
      _currentLanguage = languageCode;
      await _storage.write(key: 'app_language', value: languageCode);
      notifyListeners();
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  // Translation helper
  String translate(String id, String en) {
    return _currentLanguage == 'en' ? en : id;
  }
}
