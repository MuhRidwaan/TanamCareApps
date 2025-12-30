import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
// Import ini sekarang akan berhasil karena file services/ai_service.dart sudah dibuat
import '../../services/ai_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  // Instance AIService sekarang valid
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
    // Load labels.txt dari assets
    try {
      final labelData = await rootBundle.loadString('assets/labels.txt');
      setState(() {
        _labels = labelData.split('\n').where((s) => s.isNotEmpty).toList();
      });
    } catch (e) {
      print("Error loading labels: $e");
      // Fallback labels jika file tidak ditemukan
      _labels = [
        "Bacterial Spot",
        "Early Blight",
        "Late Blight",
        "Leaf Mold",
        "Septoria Leaf Spot",
        "Spider Mites",
        "Target Spot",
        "Yellow Leaf Curl Virus",
        "Mosaic Virus",
        "Healthy"
      ];
    }
  }

  @override
  void dispose() {
    _aiService.close();
    super.dispose();
  }

  // Fungsi ambil gambar
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600, // Kompres sedikit agar tidak berat di memori
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _result = null; // Reset hasil sebelumnya
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Fungsi Scan AI
  Future<void> _startScan() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih gambar terlebih dahulu!")),
      );
      return;
    }

    // On Web, AI inferencing is not supported (dart:ffi native libraries aren't available).
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fitur AI tidak tersedia di Web. Coba di perangkat Android atau iOS.')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    // Jalankan prediksi
    final result = await _aiService.analyzeImage(_selectedImage!, _labels);

    setState(() {
      _isAnalyzing = false;
      _result = result;
    });

    if (result != null) {
      // Tampilkan Modal/Dialog Hasil
      _showResultDialog(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menganalisis gambar.")),
      );
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text(
                "Hasil Deteksi: ${result['label']}",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Tingkat Keyakinan: ${result['confidence']}%",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Tutup",
                      style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Scan Penyakit",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Arahkan kamera ke daun atau bagian tanaman yang sakit.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // --- AREA GAMBAR ---
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: CustomPaint(
                  foregroundPainter: _selectedImage == null
                      ? _DashedBorderPainter(color: Colors.green.shade300)
                      : null, // Hilangkan garis jika gambar sudah ada
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
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
                              const Icon(Icons.photo_camera_outlined,
                                  size: 80, color: Colors.green),
                              const SizedBox(height: 10),
                              const Text("Ketuk untuk pilih Galeri",
                                  style: TextStyle(color: Colors.black54)),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt,
                                    color: Color(0xFF2ECC71)),
                                label: const Text("Buka Kamera",
                                    style: TextStyle(color: Color(0xFF2ECC71))),
                              )
                            ],
                          )
                        : Stack(
                            children: [
                              Positioned(
                                top: 10,
                                right: 10,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _selectedImage = null;
                                        _result = null;
                                      });
                                    },
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
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _startScan,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.search),
                  label: Text(
                    _isAnalyzing ? "MENGANALISIS..." : "SCAN PENYAKIT",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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

// Custom Painter untuk garis putus-putus
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
        const Radius.circular(16),
      ));

    // Simple dash effect
    const double dashWidth = 5;
    const double dashSpace = 5;
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
