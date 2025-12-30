import 'package:flutter/material.dart';

class PlantProgressScreen extends StatelessWidget {
  const PlantProgressScreen({super.key});

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
          "Progress Tanaman",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Lihat pemantauan dan pertumbuhan setiap tanaman Anda di sini. (Placeholder)',
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // Placeholder card list
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.eco, color: Colors.green),
                      ),
                      title: Text('Tanaman ${index + 1}'),
                      subtitle: const Text('Pertumbuhan: 35% • Keterangan singkat'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: navigate to detailed plant progress screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Detail progress belum diimplementasikan')),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
