import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/garden_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/translations.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final garden = Provider.of<GardenProvider>(context, listen: false);
      garden.loadUserPlants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.currentLanguage;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2ECC71),
        title: Text(
          Translations.get(Translations.myGarden, lang),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "${user?.name ?? 'Petani'}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<GardenProvider>(
        builder: (context, gardenProvider, _) {
          // Loading state
          if (gardenProvider.isLoading && gardenProvider.userPlants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF2ECC71),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Memuat data kebun...",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (gardenProvider.userPlants.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2ECC71).withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.local_florist,
                        size: 80,
                        color: Color(0xFF2ECC71),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      Translations.get(Translations.noPlants, lang),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Translations.get(Translations.noPlantsDesc, lang),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.add),
                      label: Text(Translations.get(Translations.addPlant, lang)),
                    ),
                  ],
                ),
              ),
            );
          }

          // List state
          return RefreshIndicator(
            onRefresh: () async {
              await gardenProvider.loadUserPlants();
            },
            color: const Color(0xFF2ECC71),
            child: CustomScrollView(
              slivers: [
                // Summary Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildSummaryCard(gardenProvider),
                  ),
                ),

                // Plants List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final plant = gardenProvider.userPlants[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildPlantProgressCard(plant),
                        );
                      },
                      childCount: gardenProvider.userPlants.length,
                    ),
                  ),
                ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(GardenProvider gardenProvider) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final lang = languageProvider.currentLanguage;
    
    final totalPlants = gardenProvider.userPlants.length;
    final healthyPlants = gardenProvider.userPlants
        .where((p) => p.status.toLowerCase() == 'healthy')
        .length;
    final seedlingPlants = gardenProvider.userPlants
        .where((p) => p.growthStage.toLowerCase().contains('seedling'))
        .length;

    return Container(
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
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Translations.get(Translations.gardenSummary, lang),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem(
                icon: Icons.local_florist,
                label: Translations.get(Translations.totalPlants, lang),
                value: totalPlants.toString(),
              ),
              _buildSummaryItem(
                icon: Icons.favorite,
                label: Translations.get(Translations.healthy, lang),
                value: healthyPlants.toString(),
              ),
              _buildSummaryItem(
                icon: Icons.grass_outlined,
                label: Translations.get(Translations.seedling, lang),
                value: seedlingPlants.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPlantProgressCard(dynamic plant) {
    final growthStagePercentage = _getGrowthStagePercentage(plant.growthStage);
    final isHealthy = plant.status.toLowerCase() == 'healthy';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHealthy ? const Color(0xFFC8E6C9) : Colors.orange[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan nama, status, dan delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.nickname,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plant.locationType,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isHealthy
                          ? const Color(0xFF2ECC71).withOpacity(0.15)
                          : Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isHealthy ? Icons.check_circle : Icons.info,
                          size: 14,
                          color: isHealthy ? const Color(0xFF2ECC71) : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isHealthy ? "Sehat" : "Perlu Perhatian",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isHealthy
                                ? const Color(0xFF2ECC71)
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                    onPressed: () => _showDeleteConfirmation(context, plant),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Growth Stage Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plant.growthStage,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF558B2F),
                      ),
                    ),
                    Text(
                      "$growthStagePercentage%",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2ECC71),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: growthStagePercentage / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isHealthy
                          ? const Color(0xFF2ECC71)
                          : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Info Details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.event_note,
                  label: "Ditanam",
                  value: plant.plantingDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.place,
                  label: "Lokasi",
                  value: plant.locationType,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2ECC71),
                    side: const BorderSide(
                      color: Color(0xFF2ECC71),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _showUpdateStatusDialog(context, plant);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Update Status"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(
                      color: Colors.red,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _showDeleteConfirmation(context, plant);
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text("Hapus"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showUpdateStatusDialog(BuildContext context, dynamic plant) {
    final stages = ['Seedling', 'Vegetative', 'Flowering', 'Fruiting', 'Mature'];
    final statuses = ['Healthy', 'Watering Needed', 'Pest Issue', 'Disease'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Status Tanaman"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Growth Stage",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: stages.map((stage) {
                  final isSelected = plant.growthStage == stage;
                  return FilterChip(
                    label: Text(stage),
                    selected: isSelected,
                    onSelected: (_) {
                      // Update logic would go here
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Status diubah menjadi $stage'),
                          backgroundColor: const Color(0xFF2ECC71),
                        ),
                      );
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFF2ECC71),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                "Status Kesehatan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: statuses.map((status) {
                  final isSelected = plant.status == status;
                  return FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Status kesehatan diubah menjadi $status'),
                          backgroundColor: const Color(0xFF2ECC71),
                        ),
                      );
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFF2ECC71),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic plant) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final lang = languageProvider.currentLanguage;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Text(Translations.get(Translations.deletePlant, lang)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${Translations.get(Translations.deleteConfirmMessage, lang)} "${plant.nickname}"?',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      Translations.get(Translations.deleteWarning, lang),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translations.get(Translations.cancel, lang)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(Translations.get(Translations.delete, lang) + '...'),
                  duration: Duration(seconds: 30),
                  backgroundColor: Colors.grey,
                ),
              );
              
              final gardenProvider = Provider.of<GardenProvider>(context, listen: false);
              print('Starting delete for plant: ${plant.id} - ${plant.nickname}');
              
              final success = await gardenProvider.deletePlant(plant.id);
              
              print('Delete result: $success');
              
              if (context.mounted) {
                // Remove loading snackbar
                ScaffoldMessenger.of(context).clearSnackBars();
                
                // Show result snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '"${plant.nickname}" ${Translations.get(Translations.plantDeleted, lang)}'
                          : Translations.get(Translations.deleteFailed, lang),
                    ),
                    backgroundColor: success ? const Color(0xFF2ECC71) : Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Text(Translations.get(Translations.delete, lang)),
          ),
        ],
      ),
    );
  }

  int _getGrowthStagePercentage(String stage) {
    switch (stage.toLowerCase()) {
      case 'seedling':
        return 20;
      case 'vegetative':
        return 40;
      case 'flowering':
        return 60;
      case 'fruiting':
        return 80;
      case 'mature':
        return 100;
      default:
        return 10;
    }
  }
}
