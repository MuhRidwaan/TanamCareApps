import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/garden_provider.dart';
import 'providers/language_provider.dart';
import 'screens/auth/login_screen.dart';
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
        ChangeNotifierProvider(create: (_) => AuthProvider()), // [cite: 153]
        ChangeNotifierProvider(create: (_) => GardenProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..loadLanguage()),
      ],
      child: MaterialApp(
        title: 'TanamCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,  // Gunakan theme terpusat
        // Arahkan langsung ke LoginScreen
        home: const LoginScreen(),
      ),
    );
  }
}
