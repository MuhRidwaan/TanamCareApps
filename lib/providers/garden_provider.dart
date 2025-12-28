import 'package:flutter/material.dart';
import '../services/plant_service.dart';
import '../models/plant_species_model.dart';
import '../models/user_plant_model.dart';
import '../core/utils/view_state.dart';
import '../core/utils/app_logger.dart';

class GardenProvider extends ChangeNotifier {
  final PlantService _plantService = PlantService();

  List<PlantSpeciesModel> _allSpecies = [];
  List<PlantSpeciesModel> get allSpecies => _allSpecies;

  List<UserPlantModel> _userPlants = [];
  List<UserPlantModel> get userPlants => _userPlants;

  ViewState _viewState = ViewState.initial;
  ViewState get viewState => _viewState;
  
  bool get isLoading => _viewState == ViewState.loading;
  bool get hasError => _viewState == ViewState.error;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Fetch semua species dari database
  Future<void> loadAllSpecies({bool forceRefresh = false}) async {
    _viewState = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _allSpecies = await _plantService.getAllSpecies(forceRefresh: forceRefresh);
      _viewState = ViewState.success;
      AppLogger.debug('Loaded ${_allSpecies.length} plant species');
    } catch (e) {
      _viewState = ViewState.error;
      _errorMessage = 'Gagal memuat data tanaman';
      AppLogger.error('Load species error', e.toString());
    }
    
    notifyListeners();
  }

  /// Fetch tanaman milik user
  Future<void> loadUserPlants({bool forceRefresh = false}) async {
    try {
      _userPlants = await _plantService.getMyPlants(forceRefresh: forceRefresh);
      AppLogger.debug('Loaded ${_userPlants.length} user plants');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Load user plants error', e.toString());
      // Don't show error for user plants as it's less critical
      // Keep existing data if any
    }
  }

  /// Tambah tanaman ke garden user
  Future<bool> addPlantToGarden({
    required int speciesId,
    required String nickname,
    required String locationType,
    String? plantingDate,
  }) async {
    try {
      final success = await _plantService.addPlantToGarden(
        speciesId: speciesId,
        nickname: nickname,
        locationType: locationType,
        plantingDate: plantingDate,
      );

      if (success) {
        // Re-load user plants setelah sukses menambah
        await loadUserPlants(forceRefresh: true);
        AppLogger.debug('Plant added to garden successfully');
      }

      return success;
    } catch (e) {
      AppLogger.error('Add plant to garden failed', e.toString());
      return false;
    }
  }

  /// Hapus tanaman dari kebun user
  Future<bool> deletePlant(int userPlantId) async {
    try {
      final success = await _plantService.deletePlant(userPlantId);

      if (success) {
        // Update state lokal agar UI langsung ter-update
        _userPlants.removeWhere((p) => p.id == userPlantId);
        AppLogger.debug('Plant deleted successfully');
        notifyListeners();
      }

      return success;
    } catch (e) {
      AppLogger.error('Delete plant failed', e.toString());
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
