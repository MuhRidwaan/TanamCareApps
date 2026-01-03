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
  
  // Hidden plants (deleted locally but not on server) - stored in memory only
  final Set<int> _hiddenPlantIds = {};

  ViewState _viewState = ViewState.initial;
  ViewState get viewState => _viewState;
  
  bool get isLoading => _viewState == ViewState.loading;
  bool get hasError => _viewState == ViewState.error;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // Last delete error for detailed feedback
  String? _lastDeleteError;
  String? get lastDeleteError => _lastDeleteError;

  /// Get visible plants (excluding hidden ones)
  List<UserPlantModel> get visibleUserPlants {
    return _userPlants.where((p) => !_hiddenPlantIds.contains(p.id)).toList();
  }

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
    AppLogger.debug('GardenProvider: Starting delete for plant ID: $userPlantId');
    _lastDeleteError = null;
    
    try {
      final success = await _plantService.deletePlant(userPlantId);
      AppLogger.debug('GardenProvider: Delete result from service: $success');

      if (success) {
        _userPlants.removeWhere((p) => p.id == userPlantId);
        _hiddenPlantIds.remove(userPlantId);
        AppLogger.debug('GardenProvider: Plant removed from local state');
        notifyListeners();
        await loadUserPlants(forceRefresh: true);
        return true;
      }

      // API delete failed - hide locally as fallback
      _lastDeleteError = 'Server tidak merespons. Tanaman disembunyikan sementara.';
      _hiddenPlantIds.add(userPlantId);
      notifyListeners();
      AppLogger.warning('GardenProvider: API delete failed, hidden locally');
      return true; // Return true because plant is hidden
    } catch (e) {
      AppLogger.error('GardenProvider: Delete plant failed', e.toString());
      _lastDeleteError = e.toString();
      // Still hide locally on error
      _hiddenPlantIds.add(userPlantId);
      notifyListeners();
      return true; // Return true because plant is hidden
    }
  }

  /// Unhide a plant (restore from local hidden list)
  void unhidePlant(int userPlantId) {
    _hiddenPlantIds.remove(userPlantId);
    notifyListeners();
  }

  /// Get list of hidden plant IDs
  Set<int> get hiddenPlantIds => _hiddenPlantIds;

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    _lastDeleteError = null;
    notifyListeners();
  }
}
