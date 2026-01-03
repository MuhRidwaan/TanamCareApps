import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/plant_species_model.dart';
import '../../providers/garden_provider.dart';
import 'plant_recommendation_screen.dart';

class PlantInputScreen extends StatefulWidget {
  final PlantSpeciesModel plant;

  const PlantInputScreen({super.key, required this.plant});

  @override
  State<PlantInputScreen> createState() => _PlantInputScreenState();
}

class _PlantInputScreenState extends State<PlantInputScreen> {
  late TextEditingController _nicknameController;
  String _selectedLocationType = "indoor";
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _errorMessage;

  // Sesuai API: location_type (indoor/outdoor/greenhouse)
  final List<Map<String, String>> _locationTypes = [
    {"value": "indoor", "label": "Indoor (Dalam Ruangan)"},
    {"value": "outdoor", "label": "Outdoor (Luar Ruangan)"},
    {"value": "greenhouse", "label": "Greenhouse (Rumah Kaca)"},
  ];

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2ECC71),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (_nicknameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama tanaman tidak boleh kosong"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final gardenProvider =
          Provider.of<GardenProvider>(context, listen: false);

      // Format tanggal ke YYYY-MM-DD sesuai API
      final dateForApi = _selectedDate != null 
          ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
          : "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

      // Add plant to garden
      final success = await gardenProvider.addPlantToGarden(
        speciesId: widget.plant.id,
        nickname: _nicknameController.text,
        locationType: _selectedLocationType,
        plantingDate: dateForApi,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (success) {
        // Navigate to recommendation screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PlantRecommendationScreen(
              plant: widget.plant,
              nickname: _nicknameController.text,
              locationType: _selectedLocationType,
              plantingDate: _selectedDate ?? DateTime.now(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menyimpan tanaman. Coba lagi."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      String errorMsg = e.toString();
      if (errorMsg.contains('Exception:')) {
        errorMsg = errorMsg.replaceAll('Exception:', '').trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
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
          "Input Data Awal",
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
              // --- NAMA TANAMAN ---
              const Text(
                "Nama Tanaman",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: "Contoh: Tomat Saya",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF1F8E9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE0F2F1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE0F2F1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2ECC71),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),

              // --- JENIS TANAH ---
              const Text(
                "Lokasi Tanam",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0F2F1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedLocationType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  items: _locationTypes.map((Map<String, String> item) {
                    return DropdownMenuItem<String>(
                      value: item['value'],
                      child: Text(
                        item['label']!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedLocationType = newValue;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // --- KARAKTERISTIK TANAH (INFO CARD) ---
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
                    const Text(
                      "Karakteristik Tanah",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSoilCharacteristic(
                      label: "Jenis Tanah",
                      value: widget.plant.soilRecommendation,
                    ),
                    const SizedBox(height: 8),
                    _buildSoilCharacteristic(
                      label: "pH Tanah",
                      value: "Netral (6.0 - 7.5)",
                    ),
                    const SizedBox(height: 8),
                    _buildSoilCharacteristic(
                      label: "Kelembaban",
                      value: "60 - 80%",
                    ),
                    const SizedBox(height: 8),
                    _buildSoilCharacteristic(
                      label: "Suhu Tanah",
                      value:
                          "${widget.plant.optimalTempMin}°C - ${widget.plant.optimalTempMax}°C",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- TANGGAL TANAM ---
              const Text(
                "Tanggal Tanam",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    border: Border.all(color: const Color(0xFFE0F2F1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month,
                          color: Color(0xFF2ECC71), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat("dd MMMM yyyy")
                            .format(_selectedDate ?? DateTime.now()),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- TOMBOL SUBMIT ---
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
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Lanjut ke Rekomendasi",
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

  Widget _buildSoilCharacteristic({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2ECC71),
          ),
        ),
      ],
    );
  }
}
