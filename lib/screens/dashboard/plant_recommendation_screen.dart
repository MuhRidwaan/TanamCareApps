import 'package:flutter/material.dart';
import '../../models/plant_species_model.dart';

class PlantRecommendationScreen extends StatefulWidget {
  final PlantSpeciesModel plant;
  final String nickname;
  final String locationType;
  final DateTime plantingDate;

  const PlantRecommendationScreen({
    super.key,
    required this.plant,
    required this.nickname,
    required this.locationType,
    required this.plantingDate,
  });

  @override
  State<PlantRecommendationScreen> createState() =>
      _PlantRecommendationScreenState();
}

class _PlantRecommendationScreenState extends State<PlantRecommendationScreen> {
  @override
  Widget build(BuildContext context) {
    // Calculate recommendation percentage (simulasi)
    int recommendationPercentage = _calculateRecommendation();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
          onPressed: () {
            // Kembali ke home
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        centerTitle: true,
        title: const Text(
          "Hasil Rekomendasi",
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- RECOMMENDATION PERCENTAGE ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2ECC71),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    // --- CIRCULAR PROGRESS ---
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: recommendationPercentage / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF2ECC71),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$recommendationPercentage%",
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2ECC71),
                              ),
                            ),
                            const Text(
                              "Layak Tanam",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Kondisi ideal untuk menanam tanaman ini",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // --- RESEP MEDIA TANAM ---
              const Text(
                "Resep Media Tanam",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 12),
              _buildRecipeCard(
                title: "Tanah Humus",
                percentage: "40%",
                description: "Tanah hitam kaya akan organik",
                icon: Icons.landscape,
                color: const Color(0xFF795548),
              ),
              const SizedBox(height: 12),
              _buildRecipeCard(
                title: "Pupuk Kandang",
                percentage: "35%",
                description: "Pupuk alami dari hewan ternak",
                icon: Icons.grain,
                color: const Color(0xFFA1887F),
              ),
              const SizedBox(height: 12),
              _buildRecipeCard(
                title: "Sekam Bakar",
                percentage: "25%",
                description: "Meningkatkan drainase dan aerasi tanah",
                icon: Icons.auto_awesome,
                color: const Color(0xFFBCAAA4),
              ),
              const SizedBox(height: 28),

              // --- REKOMENDASI TAMBAHAN ---
              const Text(
                "Rekomendasi Tambahan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 12),
              _buildRecommendationItem(
                icon: Icons.info_outline,
                title: "Persiapan Lokasi",
                description:
                    "Pastikan lokasi ${widget.locationType.toLowerCase()} mendapat sinar matahari ${widget.plant.sunlightNeeds.toLowerCase()}",
                type: "info",
              ),
              const SizedBox(height: 10),
              _buildRecommendationItem(
                icon: Icons.warning_amber,
                title: "Perhatian Hama",
                description:
                    "Monitor secara berkala untuk mencegah serangan hama dan penyakit tanaman",
                type: "warning",
              ),
              const SizedBox(height: 10),
              _buildRecommendationItem(
                icon: Icons.done_all,
                title: "Perawatan Rutin",
                description:
                    "Siram tanaman secara teratur dan berikan pupuk sesuai jadwal yang ditentukan",
                type: "success",
              ),
              const SizedBox(height: 28),

              // --- INFORMASI TANAMAN ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0F2F1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Data Tanaman Anda",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDataRow("Nama Tanaman", widget.nickname),
                    _buildDataRow("Jenis Tanaman", widget.plant.name),
                    _buildDataRow("Lokasi", widget.locationType),
                    _buildDataRow("Durasi Panen",
                        "${widget.plant.harvestDurationDays} hari"),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // --- TOMBOL SELESAI ---
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
                    // Back to home
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    "Selesai",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateRecommendation() {
    // Simulasi perhitungan berdasarkan kondisi
    int base = 85;

    // Adjust berdasarkan lokasi
    if (widget.locationType == "Ground") {
      base += 5;
    } else if (widget.locationType == "Pot") {
      base -= 5;
    }

    return base.clamp(0, 100);
  }

  Widget _buildRecipeCard({
    required String title,
    required String percentage,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      percentage,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2ECC71),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required String title,
    required String description,
    required String type,
  }) {
    Color bgColor;
    Color iconColor;

    if (type == "warning") {
      bgColor = Colors.orange.withOpacity(0.1);
      iconColor = Colors.orange;
    } else if (type == "success") {
      bgColor = Colors.green.withOpacity(0.1);
      iconColor = Colors.green;
    } else {
      bgColor = Colors.blue.withOpacity(0.1);
      iconColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: iconColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }
}
