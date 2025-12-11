import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  late Future<Map<String, dynamic>> _weatherFuture;

  @override
  void initState() {
    super.initState();
    // Panggil cuaca saat halaman dibuka
    // Nanti bisa diganti lat/long dari profil user jika ada
    _weatherFuture = _weatherService.getCurrentWeather();

    // Opsional: Pastikan data user ter-load jika belum ada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user == null) {
        auth.loadUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data user dari Provider
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER DINAMIS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tampilkan Nama User atau 'Petani' jika loading/null
                      Text(
                        "Haii, ${user?.name ?? 'Petani'}!",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Siap Menanam Hari Ini",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  // --- CUACA REAL-TIME ---
                  FutureBuilder<Map<String, dynamic>>(
                    future: _weatherFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2));
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Icon(Icons.error_outline,
                            color: Colors.grey);
                      }

                      final temp = snapshot.data?['temperature'] ?? 0;
                      // Kode cuaca OpenMeteo: 0=Cerah, 1-3=Berawan, >50=Hujan
                      // Kita sederhanakan icon-nya
                      return Row(
                        children: [
                          const Icon(Icons.wb_sunny_outlined,
                              color: Colors.orange),
                          const SizedBox(width: 6),
                          Text(
                            "$temp °C",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  )
                ],
              ),
              const SizedBox(height: 20),

              // --- SISA KODE LAINNYA TETAP SAMA ---
              // (Search Bar, Banner, Grid Populer jangan dihapus)
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildRecommendationBanner(),
              const SizedBox(height: 25),
              const Text("Populer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildPopularGrid(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Helper (Salin ulang bagian bawah kode sebelumnya kesini) ---
  // Agar kode terlihat rapi, saya buat method terpisah
  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Cari Tanaman..",
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: const Icon(Icons.search, color: Colors.black),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRecommendationBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF43A047),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Rekomendasi Hari Ini",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: const [
                    Icon(Icons.schedule, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text("Waktu Siram Tanaman:\n06.00 - 09.00",
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Icon(Icons.eco, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text("Pemupukan\nSekali Seminggu",
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 1,
            child: Icon(Icons.local_florist_rounded,
                size: 80, color: Colors.white30),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.85,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildPlantCard("Tomat", Icons.circle, Colors.red),
        _buildPlantCard("Wortel", Icons.change_history, Colors.orange),
        _buildPlantCard("Timun", Icons.rounded_corner, Colors.green),
        _buildPlantCard("Kentang", Icons.landscape, Colors.brown),
      ],
    );
  }

  Widget _buildPlantCard(String name, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: color),
          const SizedBox(height: 10),
          Text(name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          SizedBox(
            height: 32,
            width: 100,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {},
              child: const Text("Tanam", style: TextStyle(fontSize: 12)),
            ),
          )
        ],
      ),
    );
  }
}
