import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/garden_provider.dart';
import 'providers/language_provider.dart';
import 'providers/history_provider.dart';
import 'providers/scan_provider.dart';
import 'screens/landing_screen.dart';
import 'core/theme/app_theme.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Daftarkan AuthProvider di sini
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GardenProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..loadLanguage()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
      ],
      child: MaterialApp(
        title: 'TanamCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,  // Gunakan theme terpusat
        // Tampilkan Landing Screen terlebih dahulu
        home: const LandingScreen(),
      ),
    );
  }
}
