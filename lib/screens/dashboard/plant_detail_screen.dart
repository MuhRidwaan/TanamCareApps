import 'package:flutter/material.dart';
import '../../models/plant_species_model.dart';
import 'plant_input_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  final PlantSpeciesModel plant;
  
  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  String? _getCustomImageAsset(String plantName) {
    final name = plantName.toLowerCase();
    const iconMap = {
      'tomat cherry': 'assets/cherry-tomato.png',
      'cherry tomato': 'assets/cherry-tomato.png',
      'cabe rawit': 'assets/cabai.png',
      'rawit chili': 'assets/cabai.png',
      'cabai': 'assets/cabai.png',
      'cabai rawit': 'assets/cabai.png',
      'chili': 'assets/cabai.png',
      'pepper': 'assets/cabai.png',
      'jagung manis': 'assets/corn.png',
      'sweet corn': 'assets/corn.png',
      'jagung': 'assets/corn.png',
      'corn': 'assets/corn.png',
    };
    return iconMap[name];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Detail Tanaman",
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- GAMBAR TANAMAN ---
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
              ),
              child: _buildPlantImage(),
            ),

            // --- CONTENT SECTION ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  Text(
                    "Menanam ${widget.plant.name}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.plant.scientificName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- DESKRIPSI ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Deskripsi",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.plant.description,
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

                  // --- PERSIAPAN SECTION ---
                  const Text(
                    "Persiapan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildPreparationItem(
                    icon: Icons.water,
                    title: "Jenis Tanah",
                    description: widget.plant.soilRecommendation,
                  ),
                  const SizedBox(height: 12),
                  _buildPreparationItem(
                    icon: Icons.straighten,
                    title: "Jarak Tanam",
                    description: widget.plant.plantingDistance,
                  ),
                  const SizedBox(height: 12),
                  _buildPreparationItem(
                    icon: Icons.wb_sunny,
                    title: "Cahaya",
                    description: widget.plant.sunlightNeeds,
                  ),
                  const SizedBox(height: 12),
                  _buildPreparationItem(
                    icon: Icons.thermostat,
                    title: "Suhu Ideal",
                    description:
                        "${widget.plant.optimalTempMin}°C - ${widget.plant.optimalTempMax}°C",
                  ),
                  const SizedBox(height: 12),
                  _buildPreparationItem(
                    icon: Icons.calendar_month,
                    title: "Durasi Panen",
                    description: "${widget.plant.harvestDurationDays} hari",
                  ),
                  const SizedBox(height: 28),

                  // --- TOMBOL INPUT DATA ---
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantInputScreen(
                              plant: widget.plant,
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.input, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            "Input Data",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantImage() {
    final customImage = _getCustomImageAsset(widget.plant.name);
    
    if (customImage != null) {
      return Center(
        child: Image.asset(
          customImage,
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      );
    }

    if (widget.plant.imageUrl.isNotEmpty) {
      return Image.network(
        widget.plant.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.local_florist,
              size: 100,
              color: Colors.green[300],
            ),
          );
        },
      );
    }

    return Center(
      child: Icon(
        Icons.local_florist,
        size: 100,
        color: Colors.green[300],
      ),
    );
  }

  Widget _buildPreparationItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2ECC71), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF558B2F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
