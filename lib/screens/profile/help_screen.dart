import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Bantuan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pusat Bantuan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Jika Anda mengalami masalah atau memiliki pertanyaan, lihat FAQ di bawah atau hubungi tim dukungan kami.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // Simple FAQ list placeholder
            _buildFaqItem(
              question: "Bagaimana cara menambahkan tanaman baru?",
              answer: "Masuk ke layar Garden dan tekan tombol + untuk menambahkan tanaman.",
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              question: "Bagaimana cara mengubah pengingat penyiraman?",
              answer: "Buka halaman tanaman yang bersangkutan lalu atur pengingat di bagian pengaturan.",
            ),
            const SizedBox(height: 20),

            // Contact button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: implement contact action (email/WA)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur kontak belum diimplementasikan')),
                  );
                },
                icon: const Icon(Icons.email_outlined),
                label: const Text('Hubungi Dukungan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(answer, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
