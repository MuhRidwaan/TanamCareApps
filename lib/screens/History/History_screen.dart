import 'package:flutter/material.dart';
import 'plant_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  final List<Map<String, dynamic>> historyData = const [
    {
      "plant": "Tomat",
      "activity": "Panen Berhasil",
      "time": "Umur 14 hari",
      "day": 14,
      "harvestDay": 30,
      "icon": Icons.check_circle,
      "color": Colors.orange,
    },
    {
      "plant": "Timun",
      "activity": "Panen Berhasil",
      "time": "Umur 7 hari",
      "day": 7,
      "harvestDay": 25,
      "icon": Icons.check_circle,
      "color": Colors.orange,
    },
    {
      "plant": "Wortel",
      "activity": "Panen Berhasil",
      "time": "3 hari lalu",
      "day": 30,
      "harvestDay": 30,
      "icon": Icons.check_circle,
      "color": Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "History Tanaman",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // =====================
          // HEADER SUMMARY
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ringkasan Panen",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Total Panen: ${historyData.length} tanaman",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Text(
                      "Keberhasilan: 100%",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // =====================
          // SECTION TITLE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.orange, size: 18),
                SizedBox(width: 6),
                Text(
                  "Sudah Dipanen",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // =====================
          // LIST HISTORY
          ...historyData.map(
            (item) => _historyCard(context, item),
          ),

          const SizedBox(height: 24),

          // =====================
          // INSIGHT CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Konsistensi perawatan meningkatkan peluang panen berhasil hingga 30%.",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================
  // HISTORY CARD
  Widget _historyCard(BuildContext context, Map<String, dynamic> item) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlantDetailScreen(plantData: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: item["color"].withOpacity(0.15),
              child: Icon(
                item["icon"],
                color: item["color"],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["plant"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item["activity"],
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    item["time"],
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
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
}
