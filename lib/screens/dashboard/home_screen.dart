import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/garden_provider.dart';
import '../../services/weather_service.dart';
import 'my_garden_screen.dart';

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
    _weatherFuture = _weatherService.getCurrentWeather();

    // Opsional: Pastikan data user ter-load jika belum ada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user == null) {
        auth.loadUser();
      }
      
      // Load semua species dan user plants
      final garden = Provider.of<GardenProvider>(context, listen: false);
      garden.loadAllSpecies();
      garden.loadUserPlants();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data user dari Provider
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER DINAMIS DENGAN BACKGROUND ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2ECC71).withOpacity(0.1),
                      const Color(0xFF27AE60).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Haii, ${user?.name ?? 'Petani'}! 👋",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Siap Menanam Hari Ini 🌱",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF558B2F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // --- CUACA REAL-TIME DENGAN CARD ---
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: _weatherFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 50,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            );
                          }

                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Icon(Icons.error_outline,
                                color: Colors.grey, size: 24);
                          }

                          final temp = snapshot.data?['temperature'] ?? 0;
                          return Row(
                            children: [
                              const Icon(Icons.wb_sunny,
                                  color: Colors.orange, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                "$temp°",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- SEARCH BAR ---
              _buildSearchBar(),
              const SizedBox(height: 24),

              // --- RECOMMENDATION BANNER ---
              _buildRecommendationBanner(),
              const SizedBox(height: 28),

              // --- POPULER SECTION HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tanaman Populer",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 3,
                        width: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  Consumer<GardenProvider>(
                    builder: (context, gardenProvider, _) {
                      final plantCount = gardenProvider.userPlants.length;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MyGardenScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF2ECC71),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_florist,
                                size: 14,
                                color: Color(0xFF2ECC71),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Kebun ($plantCount)",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2ECC71),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPopularGrid(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari tanaman...",
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 12),
            child: Icon(Icons.search, color: Color(0xFF2ECC71), size: 24),
          ),
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.tune, color: Colors.grey, size: 20),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF2ECC71),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2ECC71),
            const Color(0xFF27AE60),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb,
                      color: Colors.white70, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    "Rekomendasi Hari Ini",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.water_drop,
                              color: Colors.white70, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Penyiraman",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  )),
                              Text("06.00 - 09.00",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.eco,
                              color: Colors.white70, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Pemupukan",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  )),
                              Text("Sekali Seminggu",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularGrid() {
    return Consumer<GardenProvider>(
      builder: (context, gardenProvider, _) {
        // Jika sedang loading
        if (gardenProvider.isLoading && gardenProvider.allSpecies.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Jika tidak ada data
        if (gardenProvider.allSpecies.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Tidak ada tanaman tersedia"),
            ),
          );
        }

        // Tampilkan grid dari database
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: gardenProvider.allSpecies.length,
          itemBuilder: (context, index) {
            final plant = gardenProvider.allSpecies[index];
            return _buildPlantCard(context, plant);
          },
        );
      },
    );
  }

  Widget _buildPlantCard(BuildContext context, dynamic plant) {
    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            _showPlantDetailsBottomSheet(context, plant);
          },
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.12),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _showPlantDetailsBottomSheet(context, plant);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Image Container dengan gradient overlay
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFE8F5E9),
                                    const Color(0xFFC8E6C9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: plant.imageUrl.isNotEmpty
                                  ? Image.network(
                                      plant.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(Icons.local_florist,
                                              size: 50,
                                              color: Colors.green[300]),
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Icon(Icons.local_florist,
                                          size: 50,
                                          color: Colors.green[300]),
                                    ),
                            ),
                            // Badge untuk kategori
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2ECC71),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Populer",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plant.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1B5E20),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plant.scientificName,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isLoading
                                      ? Colors.grey[300]
                                      : const Color(0xFF2ECC71),
                                  foregroundColor: Colors.white,
                                  elevation: isLoading ? 0 : 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        setState(() => isLoading = true);

                                        final garden =
                                            Provider.of<GardenProvider>(
                                              context,
                                              listen: false,
                                            );
                                        final success =
                                            await garden.addPlantToGarden(
                                          speciesId: plant.id,
                                          nickname: plant.name,
                                          locationType: 'indoor',
                                        );

                                        setState(() => isLoading = false);

                                        if (mounted) {
                                          if (success) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${plant.name} ditambahkan ke kebun Anda ✓',
                                                ),
                                                backgroundColor:
                                                    const Color(0xFF2ECC71),
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                margin:
                                                    const EdgeInsets.all(16),
                                                shape:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    12,
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Gagal menambahkan tanaman',
                                                ),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 2),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                margin: EdgeInsets.all(16),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                child: isLoading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        "Tanam",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPlantDetailsBottomSheet(
    BuildContext context,
    dynamic plant,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- HANDLE BAR ---
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- HEADER SECTION ---
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plant.name,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B5E20),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    plant.scientificName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (plant.imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 90,
                                  width: 90,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFE8F5E9),
                                        const Color(0xFFC8E6C9),
                                      ],
                                    ),
                                  ),
                                  child: Image.network(
                                    plant.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(Icons.local_florist,
                                            size: 50,
                                            color: Colors.green[300]),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- DESKRIPSI ---
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFC8E6C9),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Deskripsi Tanaman",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                plant.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.6,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- INFO DETAIL DENGAN LAYOUT LEBIH BAIK ---
                        const Text(
                          "Informasi Penting",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.05,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            _buildInfoCard(
                              icon: Icons.thermostat,
                              title: "Suhu Optimal",
                              value:
                                  "${plant.optimalTempMin}°C - ${plant.optimalTempMax}°C",
                            ),
                            _buildInfoCard(
                              icon: Icons.wb_sunny,
                              title: "Cahaya",
                              value: plant.sunlightNeeds,
                            ),
                            _buildInfoCard(
                              icon: Icons.space_dashboard,
                              title: "Jarak Tanam",
                              value: plant.plantingDistance,
                            ),
                            _buildInfoCard(
                              icon: Icons.calendar_month,
                              title: "Durasi Panen",
                              value: "${plant.harvestDurationDays} hari",
                            ),
                            _buildInfoCard(
                              icon: Icons.water,
                              title: "Jenis Tanah",
                              value: plant.soilRecommendation,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // --- TOMBOL TANAM DENGAN GRADIENT ---
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2ECC71),
                                Color(0xFF27AE60),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2ECC71).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  final garden = Provider.of<GardenProvider>(
                                    context,
                                    listen: false,
                                  );
                                  final success =
                                      await garden.addPlantToGarden(
                                    speciesId: plant.id,
                                    nickname: plant.name,
                                    locationType: 'indoor',
                                  );

                                  if (mounted) {
                                    Navigator.pop(context);
                                    if (success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${plant.name} ditambahkan ke kebun Anda ✓',
                                          ),
                                          backgroundColor:
                                              const Color(0xFF2ECC71),
                                          duration: const Duration(seconds: 2),
                                          behavior:
                                              SnackBarBehavior.floating,
                                          margin: const EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Gagal menambahkan tanaman',
                                          ),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 2),
                                          behavior:
                                              SnackBarBehavior.floating,
                                          margin: EdgeInsets.all(16),
                                        ),
                                      );
                                    }
                                  }
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.agriculture,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Tanam Sekarang",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC8E6C9),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: const Color(0xFF2ECC71),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF558B2F),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
