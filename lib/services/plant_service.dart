import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/utils/app_logger.dart';
import '../models/plant_species_model.dart';
import '../models/user_plant_model.dart';
import '../models/log_model.dart';

class PlantService {
  final ApiClient _client = ApiClient();
  
  // Simple caching
  List<PlantSpeciesModel>? _cachedSpecies;
  List<UserPlantModel>? _cachedMyPlants;
  DateTime? _speciesCacheTime;
  DateTime? _myPlantsCacheTime;
  
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Ambil semua plant species dari database dengan caching
  Future<List<PlantSpeciesModel>> getAllSpecies({bool forceRefresh = false}) async {
    // Check cache
    if (!forceRefresh && _cachedSpecies != null && _speciesCacheTime != null) {
      final isExpired = DateTime.now().difference(_speciesCacheTime!) > _cacheExpiry;
      if (!isExpired) {
        AppLogger.debug('Using cached species data');
        return _cachedSpecies!;
      }
    }

    try {
      final response = await _retryRequest(() => _client.dio.get(Endpoints.species));
      
      List<PlantSpeciesModel> species = [];
      
      if (response.data is List) {
        species = (response.data as List)
            .map((item) => PlantSpeciesModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.data is Map && response.data['data'] != null) {
        species = (response.data['data'] as List)
            .map((item) => PlantSpeciesModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      // Cache the result
      _cachedSpecies = species;
      _speciesCacheTime = DateTime.now();
      AppLogger.debug('Cached ${species.length} species');
      
      return species;
    } on DioException catch (e) {
      AppLogger.error('Get Species Error', e.response?.data);
      // Return cached data if available, otherwise empty list
      return _cachedSpecies ?? [];
    }
  }

  /// Ambil tanaman user dengan caching
  Future<List<UserPlantModel>> getMyPlants({bool forceRefresh = false}) async {
    // Check cache
    if (!forceRefresh && _cachedMyPlants != null && _myPlantsCacheTime != null) {
      final isExpired = DateTime.now().difference(_myPlantsCacheTime!) > _cacheExpiry;
      if (!isExpired) {
        AppLogger.debug('Using cached my plants data');
        return _cachedMyPlants!;
      }
    }

    try {
      final response = await _retryRequest(() => _client.dio.get(Endpoints.myPlants));
      
      List<UserPlantModel> plants = [];
      
      if (response.data is List) {
        plants = (response.data as List)
            .map((item) => UserPlantModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.data is Map && response.data['data'] != null) {
        plants = (response.data['data'] as List)
            .map((item) => UserPlantModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      // Cache the result
      _cachedMyPlants = plants;
      _myPlantsCacheTime = DateTime.now();
      AppLogger.debug('Cached ${plants.length} user plants');
      
      return plants;
    } on DioException catch (e) {
      AppLogger.error('Get My Plants Error', e.response?.data);
      return _cachedMyPlants ?? [];
    }
  }

  /// Tambah tanaman ke database (simpan ke user_plants)
  Future<bool> addPlantToGarden({
    required int speciesId,
    required String nickname,
    required String locationType,
    String? plantingDate,
  }) async {
    try {
      final data = {
        'species_id': speciesId,
        'nickname': nickname,
        'location_type': locationType,
        'planting_date': plantingDate ?? DateTime.now().toString().split(' ')[0],
      };

      final response = await _retryRequest(() => 
        _client.dio.post(Endpoints.myPlants, data: data)
      );
      
      final success = response.statusCode == 200 || response.statusCode == 201;
      if (success) {
        invalidateMyPlantsCache(); // Clear cache after adding
        AppLogger.debug('Plant added to garden successfully');
      }
      
      return success;
    } on DioException catch (e) {
      AppLogger.error('Add Plant Error', e.response?.data);
      throw Exception('Gagal menambahkan tanaman: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  /// Ambil semua logs aktivitas user
  Future<List<LogModel>> getAllLogs() async {
    try {
      final response = await _client.dio.get(Endpoints.logs);
      
      if (response.data is List) {
        return (response.data as List)
            .map((item) => LogModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      // Jika response berbentuk {data: [...]}
      if (response.data is Map && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((item) => LogModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      print("Get Logs Error: ${e.response?.data}");
      return [];
    }
  }

  /// Tambah log aktivitas baru
  Future<bool> addLog({
    required int userPlantId,
    required String activityType,
    required String description,
    String? logDate,
  }) async {
    try {
      final data = {
        'user_plant_id': userPlantId,
        'activity_type': activityType,
        'description': description,
        'log_date': logDate ?? DateTime.now().toString().split(' ')[0],
      };

      final response = await _client.dio.post(Endpoints.logs, data: data);
      
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print("Add Log Error: ${e.response?.data}");
      return false;
    }
  }

  /// Hapus tanaman dari kebun user
  Future<bool> deletePlant(int userPlantId) async {
    final url = '${Endpoints.myPlants}/$userPlantId';
    try {
      AppLogger.debug('Attempting to delete plant with ID: $userPlantId');
      
      final response = await _retryRequest(() => _client.dio.delete(url));
      
      AppLogger.debug('Delete response status: ${response.statusCode}');
      
      final success = response.statusCode == 200 || response.statusCode == 204;
      if (success) {
        invalidateMyPlantsCache(); // Clear cache after deletion
        AppLogger.debug('Plant deleted successfully');
      }
      
      return success;
    } on DioException catch (e) {
      AppLogger.error('Delete Plant DioException', 
        'Status: ${e.response?.statusCode}, Data: ${e.response?.data}');

      // Fallback untuk backend Laravel/shared-hosting yang kadang memblokir HTTP DELETE
      final status = e.response?.statusCode;
      if (status == 404 || status == 405) {
        try {
          AppLogger.debug('Trying method spoofing delete via POST _method=DELETE');
          final fallbackResponse = await _retryRequest(() => 
            _client.dio.post(url, data: const {'_method': 'DELETE'})
          );
          
          final success = fallbackResponse.statusCode == 200 ||
              fallbackResponse.statusCode == 204;
          
          if (success) {
            invalidateMyPlantsCache();
            AppLogger.debug('Plant deleted via fallback method');
          }
          
          return success;
        } catch (fallbackError) {
          AppLogger.error('Fallback delete error', fallbackError.toString());
        }
      }
      
      throw Exception('Gagal menghapus tanaman: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      AppLogger.error('Delete Plant Unexpected Error', e.toString());
      throw Exception('Terjadi kesalahan tidak terduga');
    }
  }

  /// Clear all cached data
  void clearCache() {
    _cachedSpecies = null;
    _cachedMyPlants = null;
    _speciesCacheTime = null;
    _myPlantsCacheTime = null;
    AppLogger.debug('Plant service cache cleared');
  }
  
  /// Invalidate specific cache
  void invalidateMyPlantsCache() {
    _cachedMyPlants = null;
    _myPlantsCacheTime = null;
    AppLogger.debug('My plants cache invalidated');
  }
  
  /// Retry request with exponential backoff
  Future<Response<T>> _retryRequest<T>(
    Future<Response<T>> Function() request, {
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        return await request();
      } on DioException catch (e) {
        attempt++;
        
        if (attempt >= maxRetries) {
          rethrow;
        }
        
        // Don't retry on client errors (4xx)
        if (e.response?.statusCode != null && 
            e.response!.statusCode! >= 400 && 
            e.response!.statusCode! < 500) {
          rethrow;
        }
        
        // Exponential backoff: 500ms, 1s, 2s
        final delay = Duration(milliseconds: 500 * (1 << (attempt - 1)));
        AppLogger.debug('Retrying request in ${delay.inMilliseconds}ms (attempt $attempt)');
        await Future.delayed(delay);
      }
    }
    
    throw Exception('Max retries exceeded');
  }
}
