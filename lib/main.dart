import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart'; 


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
      ],
      child: MaterialApp(
        title: 'TanamCare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        // Arahkan langsung ke LoginScreen
        home: const LoginScreen(),
      ),
    );
  }
}
