import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import '../../services/ai_service.dart';
// Import file data penyakit yang baru dibuat
import 'disease_data.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final AIService _aiService = AIService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;
  List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    await _aiService.loadModel();
    try {
      final labelData = await rootBundle.loadString('assets/labels.txt');
      setState(() {
        _labels = labelData
            .split('\n')
            .map((e) => e.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      });
    } catch (e) {
      print("Error loading labels: $e");
      // Fallback labels
      _labels = [
        'bacterial_spot',
        'early_blight',
        'healthy',
        'late_blight',
        'leaf_mold',
        'septoria_leaf_spot',
        'spotted_spider_mite',
        'target_spot',
        'yellow_leaf_curl_virus'
      ];
    }
  }

  @override
  void dispose() {
    _aiService.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: source, maxWidth: 600);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _result = null;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _startScan() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih gambar terlebih dahulu!")),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    final result = await _aiService.analyzeImage(_selectedImage!, _labels);

    setState(() {
      _isAnalyzing = false;
      _result = result;
    });

    if (result != null) {
      _showResultDialog(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menganalisis gambar.")),
      );
    }
  }

  // --- BAGIAN INI YANG DI-UPGRADE TOTAL BIAR MANTAP ---
  void _showResultDialog(Map<String, dynamic> result) {
    // String rawLabel = result['label'];
    String rawLabel = result['label'].toString().trim();
    print("Mencari data untuk: '$rawLabel'");
    // Ambil data dari DiseaseData, kalau gak ada pakai data default
    var info = DiseaseData.list[rawLabel] ??
        {
          'name': rawLabel,
          'description': 'Data belum tersedia untuk penyakit ini.',
          'treatment': 'Konsultasikan dengan ahli pertanian.'
        };

    // Pakai DraggableScrollableSheet biar panelnya bisa digeser naik turun
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65, // Tinggi awal 65% layar
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: ListView(
                controller: controller,
                children: [
                  // Garis kecil buat penanda bisa digeser
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  // Ikon & Judul Utama
                  Center(
                    child: Icon(
                      rawLabel == 'healthy'
                          ? Icons.verified_user_rounded
                          : Icons.warning_amber_rounded,
                      color: rawLabel == 'healthy'
                          ? Colors.green
                          : Colors.orange[800],
                      size: 70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    info['name']!,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Badge Akurasi
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade100)),
                      child: Text(
                        "Tingkat Keyakinan AI: ${result['confidence']}%",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Bagian Gejala
                  _buildSectionTitle("🔍 Gejala & Ciri-ciri"),
                  Text(
                    info['description']!,
                    style: const TextStyle(
                        fontSize: 16, height: 1.6, color: Colors.black87),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),

                  // Bagian Solusi (Kotak Hijau)
                  _buildSectionTitle("💊 Solusi & Penanganan"),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9), // Hijau muda banget
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC5E1A5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info['treatment']!,
                          style: const TextStyle(
                              fontSize: 15,
                              height: 1.8,
                              color: Color(0xFF33691E)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Tombol Tutup
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text("Tutup",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Scan Penyakit",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Arahkan kamera ke daun atau bagian tanaman yang sakit untuk diagnosa otomatis.",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 30),

              // --- AREA GAMBAR (KODE LAMA TETAP ADA) ---
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: CustomPaint(
                  foregroundPainter: _selectedImage == null
                      ? _DashedBorderPainter(color: Colors.green.shade300)
                      : null,
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded,
                                  size: 80, color: Colors.green.shade200),
                              const SizedBox(height: 16),
                              Text("Ketuk untuk ambil dari Galeri",
                                  style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text("Buka Kamera"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.green,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                              )
                            ],
                          )
                        : Stack(
                            children: [
                              Positioned(
                                top: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImage = null;
                                      _result = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              )
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- TOMBOL SCAN ---
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _startScan,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Icon(Icons.search_rounded, size: 26),
                  label: Text(
                    _isAnalyzing ? "MENGANALISIS..." : "DIAGNOSA SEKARANG",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF2ECC71).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter tetap sama
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ));

    const double dashWidth = 8;
    const double dashSpace = 6;
    double distance = 0.0;

    final Path dashedPath = Path();
    for (ui.PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashedPath.addPath(
            metric.extractPath(distance, distance + dashWidth), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
