import 'package:flutter/material.dart';
import 'dashboard/home_screen.dart';
import 'history/history_screen.dart'; // Pastikan file ini ada
import 'profile/profile_screen.dart';
import 'scan/scan_screen.dart'; // Import file AI Scan yang asli

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar halaman
    _pages = const [
      HomeScreen(),
      ScanScreen(), // ✅ PERBAIKAN: Pakai ScanScreen asli (Fitur AI), BUKAN Placeholder
      HistoryScreen(), // Fitur History
      ProfileScreen(), // Fitur Profile
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga agar halaman tidak refresh saat pindah tab (Performa lebih baik)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type:
            BottomNavigationBarType.fixed, // Agar 4 icon muat dan label muncul
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
