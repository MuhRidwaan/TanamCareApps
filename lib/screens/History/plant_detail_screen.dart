import 'package:flutter/material.dart';

class PlantDetailScreen extends StatelessWidget {
  final Map<String, dynamic> plantData;

  const PlantDetailScreen({super.key, required this.plantData});

  @override
  Widget build(BuildContext context) {
    // ================= NULL SAFE =================
    final String plant = plantData["plant"] ?? "Tanaman";
    final int day = plantData["day"] ?? 0;
    final int harvestDay = plantData["harvestDay"] ?? 30;
    final String quality = plantData["quality"] ?? "Baik";

    final int daysAgo = (plant.hashCode % 4) + 1;

    final evaluation = _evaluationByPlant(plant);
    final recommendation = _recommendationByPlant(plant);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        centerTitle: true,
        title: Text(plant),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _statusCard(daysAgo),
          const SizedBox(height: 24),
          Row(
            children: [
              _summary("Umur Panen", "$harvestDay hari"),
              const SizedBox(width: 12),
              _summary("Dipanen", "$daysAgo hari lalu"),
              const SizedBox(width: 12),
              _summary("Kualitas", quality),
            ],
          ),
          const SizedBox(height: 24),
          _section("Evaluasi Tanaman"),
          ...evaluation.map((e) => _bullet(Icons.check_circle, e)),
          const SizedBox(height: 24),
          _section("Rekomendasi Tanam Berikutnya"),
          ...recommendation.map((r) => _bullet(Icons.arrow_forward, r)),
          const SizedBox(height: 32),
          const Divider(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: const Text(
                "Tanam Lagi",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _showReplant(context),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _statusCard(int daysAgo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🌾 Sudah Dipanen",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const LinearProgressIndicator(value: 1),
          const SizedBox(height: 8),
          Text("Dipanen $daysAgo hari lalu"),
        ],
      ),
    );
  }

  Widget _summary(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _bullet(IconData icon, String text) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.green),
      title: Text(text),
    );
  }

  // ================= LOGIC =================

  List<String> _evaluationByPlant(String plant) {
    switch (plant) {
      case "Tomat":
        return [
          "Produksi buah merata",
          "Warna buah optimal",
          "Panen sesuai estimasi",
        ];
      case "Timun":
        return [
          "Pertumbuhan cepat",
          "Ukuran buah bervariasi",
          "Butuh nutrisi tambahan",
        ];
      case "Wortel":
        return [
          "Umbi tumbuh seragam",
          "Tekstur tanah baik",
          "Kelembaban stabil",
        ];
      default:
        return [
          "Evaluasi umum tersedia",
        ];
    }
  }

  List<String> _recommendationByPlant(String plant) {
    switch (plant) {
      case "Tomat":
        return [
          "Tambahkan pupuk  di minggu ke-3",
          "Gunakan air lebih awal",
          "Estimasi panen berikutnya: 23 hari",
        ];
      case "Timun":
        return [
          "Perbaiki ph tanah",
          "Tambah pupuk organik",
          "Estimasi panen berikutnya: 23 hari",
        ];
      case "Wortel":
        return [
          "Gemburkan tanah lebih dalam",
          "Kurangi air di akhir fase",
          "Estimasi panen berikutnya: 28 hari",
        ];
      default:
        return [
          "Ikuti perawatan standar",
        ];
    }
  }

  void _showReplant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Mulai Siklus Baru 🌱",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Tanaman akan ditanam ulang dari hari ke-0.",
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("🌱 Tanaman berhasil ditanam kembali"),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text("Konfirmasi"),
            ),
          ],
        ),
      ),
    );
  }
}
