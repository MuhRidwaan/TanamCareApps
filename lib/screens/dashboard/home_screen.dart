import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/garden_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/translations.dart';
import '../../services/weather_service.dart';
import '../../models/plant_species_model.dart';
import 'plant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  late Future<Map<String, dynamic>> _weatherFuture;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _weatherFuture = _weatherService.getCurrentWeather();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user == null) {
        auth.loadUser();
      }

      final garden = Provider.of<GardenProvider>(context, listen: false);
      garden.loadAllSpecies();
      garden.loadUserPlants();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.currentLanguage;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2ECC71).withOpacity(0.15),
                      const Color(0xFF27AE60).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${Translations.get(Translations.greeting, lang)}, ${user?.name ?? 'Bona'}! 👋",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Translations.get(Translations.readyToPlant, lang),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF558B2F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.1),
                            blurRadius: 6,
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
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            );
                          }

                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Icon(Icons.error_outline,
                                color: Colors.grey, size: 20);
                          }

                          final temp = snapshot.data?['temperature'] ?? 0;
                          return Row(
                            children: [
                              const Icon(Icons.wb_sunny,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                "$temp°C",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
              const SizedBox(height: 20),

              // --- SEARCH BAR ---
              _buildSearchBar(lang),
              const SizedBox(height: 20),

              // --- RECOMMENDATION BANNER ---
              _buildRecommendationBanner(lang),
              const SizedBox(height: 24),

              // --- POPULER SECTION HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Translations.get(Translations.popularPlants, lang),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 3,
                          width: 35,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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

  Widget _buildSearchBar(String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2ECC71).withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: Translations.get(Translations.searchPlant, lang),
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 16, right: 12),
              child: Icon(Icons.search, color: Color(0xFF2ECC71), size: 22),
            ),
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.tune, color: Colors.grey, size: 18),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF2ECC71),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationBanner(String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2ECC71),
              const Color(0xFF27AE60),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2ECC71).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb,
                    color: Colors.white70, size: 22),
                const SizedBox(width: 10),
                Text(
                  Translations.get(Translations.todayRecommendation, lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              child: Column(
                children: [
                  _buildRecommendationItem(
                    icon: Icons.water_drop,
                    title: Translations.get(Translations.watering, lang),
                    subtitle: "06.00 - 09.00",
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 10),
                  _buildRecommendationItem(
                    icon: Icons.eco,
                    title: Translations.get(Translations.fertilizing, lang),
                    subtitle: Translations.get(Translations.onceAWeek, lang),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white70, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  )),
              Text(subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularGrid() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.currentLanguage;
    
    return Consumer<GardenProvider>(
      builder: (context, gardenProvider, _) {
        if (gardenProvider.isLoading && gardenProvider.allSpecies.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (gardenProvider.allSpecies.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(lang == 'en' ? "No plants available" : "Tidak ada tanaman tersedia"),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.82,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: gardenProvider.allSpecies.length,
            itemBuilder: (context, index) {
              final plant = gardenProvider.allSpecies[index];
              return _buildPlantCard(context, plant, lang);
            },
          ),
        );
      },
    );
  }

  Widget _buildPlantCard(BuildContext context, PlantSpeciesModel plant, String lang) {
    // Map plant names to icons or images
    final plantData = _getPlantIconData(plant.name.toLowerCase());
    final plantColor = plantData['color'] as Color;
    final isImage = plantData['isImage'] as bool? ?? false;
    final imagePath = plantData['image'] as String?;
    final plantIcon = plantData['icon'] as IconData?;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailScreen(plant: plant),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container dengan icon atau image file
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              child: Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      plantColor.withOpacity(0.2),
                      plantColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: isImage && imagePath != null
                      ? Image.asset(
                          imagePath,
                          width: 70,
                          height: 70,
                          fit: BoxFit.contain,
                        )
                      : Icon(
                          plantIcon ?? Icons.local_florist,
                          size: 60,
                          color: plantColor,
                        ),
                ),
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Tanam button
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PlantDetailScreen(plant: plant),
                          ),
                        );
                      },
                      child: Text(
                        Translations.get(Translations.plant, lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Map<String, dynamic> _getPlantIconData(String plantName) {
    final iconMap = {
      'tomat cherry': {'icon': Icons.favorite, 'color': const Color(0xFFE74C3C), 'image': 'assets/cherry-tomato.png', 'isImage': true},
      'cherry tomato': {'icon': Icons.favorite, 'color': const Color(0xFFE74C3C), 'image': 'assets/cherry-tomato.png', 'isImage': true},
      'cabe rawit': {'icon': Icons.local_fire_department, 'color': const Color(0xFFE74C3C), 'image': 'assets/cabai.png', 'isImage': true},
      'rawit chili': {'icon': Icons.local_fire_department, 'color': const Color(0xFFE74C3C), 'image': 'assets/cabai.png', 'isImage': true},
      'cabai': {'icon': Icons.local_fire_department, 'color': const Color(0xFFE74C3C), 'image': 'assets/cabai.png', 'isImage': true},
      'cabai rawit': {'icon': Icons.local_fire_department, 'color': const Color(0xFFE74C3C), 'image': 'assets/cabai.png', 'isImage': true},
      'chili': {'icon': Icons.local_fire_department, 'color': const Color(0xFFE74C3C), 'image': 'assets/cabai.png', 'isImage': true},
      'pepper': {'icon': Icons.local_fire_department, 'color': const Color(0xFFE74C3C), 'image': 'assets/cabai.png', 'isImage': true},
      'jagung manis': {'icon': Icons.auto_awesome, 'color': const Color(0xFFF1C40F), 'image': 'assets/corn.png', 'isImage': true},
      'sweet corn': {'icon': Icons.auto_awesome, 'color': const Color(0xFFF1C40F), 'image': 'assets/corn.png', 'isImage': true},
      'jagung': {'icon': Icons.auto_awesome, 'color': const Color(0xFFF1C40F), 'image': 'assets/corn.png', 'isImage': true},
      'corn': {'icon': Icons.auto_awesome, 'color': const Color(0xFFF1C40F), 'image': 'assets/corn.png', 'isImage': true},
    };
    return iconMap[plantName] ?? {'icon': Icons.local_florist, 'color': const Color(0xFF2ECC71)};
  }
}

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 35,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFE74C3C),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE74C3C).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          Positioned(
            left: 5,
            top: 10,
            child: Container(
              width: 10,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 8,
              height: 15,
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
