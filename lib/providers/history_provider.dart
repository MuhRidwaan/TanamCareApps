import 'package:flutter/material.dart';
import '../services/plant_service.dart';
import '../services/scan_service.dart';
import '../models/log_model.dart';
import '../models/scan_result_model.dart';
import '../core/utils/app_logger.dart';

/// HistoryProvider - Provider untuk mengelola history care logs, monitoring logs, dan scan history
/// Sesuai dokumentasi API TanamCare
class HistoryProvider extends ChangeNotifier {
  final PlantService _plantService = PlantService();
  final ScanService _scanService = ScanService();

  // Care Logs (aktivitas perawatan: watering, fertilizing, pruning, pest_control)
  List<CareLogModel> _careLogs = [];
  List<CareLogModel> get careLogs => _careLogs;

  // Monitoring Logs (kondisi tanaman: height_cm, leaf_count, condition)
  List<LogModel> _logs = [];
  List<LogModel> get logs => _logs;

  // Scan History (hasil scan AI dari tabel scan_histories)
  List<ScanResultModel> _scanHistory = [];
  List<ScanResultModel> get scanHistory => _scanHistory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ============ CARE LOGS (Aktivitas Perawatan) ============

  /// Load semua care logs dari API
  /// GET /care-logs
  Future<void> loadCareLogs({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.debug('HistoryProvider: Loading care logs...');
      _careLogs = await _plantService.getAllCareLogs();
      AppLogger.debug('HistoryProvider: Loaded ${_careLogs.length} care logs');
      
      if (_careLogs.isEmpty) {
        AppLogger.debug('HistoryProvider: Care logs empty - might be no data yet');
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat history aktivitas';
      AppLogger.error('HistoryProvider: Load care logs error', e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  // ============ SCAN HISTORY (Hasil Scan AI) ============

  /// Load semua scan history dari API
  /// GET /scans
  Future<void> loadScanHistory({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.debug('HistoryProvider: Loading scan history...');
      _scanHistory = await _scanService.getScanHistory();
      AppLogger.debug('HistoryProvider: Loaded ${_scanHistory.length} scan history');
      
      if (_scanHistory.isEmpty) {
        AppLogger.debug('HistoryProvider: Scan history empty - might be no scans yet');
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat history scan';
      AppLogger.error('HistoryProvider: Load scan history error', e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get scan history untuk tanaman tertentu
  List<ScanResultModel> getScanHistoryForPlant(int userPlantId) {
    return _scanHistory.where((scan) => scan.userPlantId == userPlantId).toList();
  }

  /// Tambah care log baru
  /// POST /care-logs - Body: user_plant_id, action_type, notes, performed_at
  Future<bool> addCareLog({
    required int userPlantId,
    required String actionType,
    String? notes,
    String? performedAt,
  }) async {
    try {
      final success = await _plantService.addCareLog(
        userPlantId: userPlantId,
        actionType: actionType,
        notes: notes,
        performedAt: performedAt,
      );

      if (success) {
        await loadCareLogs(forceRefresh: true);
      }

      return success;
    } catch (e) {
      AppLogger.error('Add care log error', e.toString());
      return false;
    }
  }

  /// Filter care logs berdasarkan action type
  List<CareLogModel> getCareLogsByType(String actionType) {
    return _careLogs.where((log) => log.actionType == actionType).toList();
  }

  /// Get care logs untuk tanaman tertentu
  List<CareLogModel> getCareLogsForPlant(int userPlantId) {
    return _careLogs.where((log) => log.userPlantId == userPlantId).toList();
  }

  // ============ MONITORING LOGS (Kondisi Tanaman) ============

  /// Load semua monitoring logs dari API
  /// GET /logs
  Future<void> loadLogs({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _logs = await _plantService.getAllLogs();
      AppLogger.debug('Loaded ${_logs.length} monitoring logs');
    } catch (e) {
      _errorMessage = 'Gagal memuat history monitoring';
      AppLogger.error('Load monitoring logs error', e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Tambah monitoring log baru
  /// POST /logs - Body: user_plant_id, log_date, height_cm, leaf_count, condition
  Future<bool> addLog({
    required int userPlantId,
    required String logDate,
    double? heightCm,
    int? leafCount,
    required String condition,
  }) async {
    try {
      final success = await _plantService.addLog(
        userPlantId: userPlantId,
        logDate: logDate,
        heightCm: heightCm,
        leafCount: leafCount,
        condition: condition,
      );

      if (success) {
        await loadLogs(forceRefresh: true);
      }

      return success;
    } catch (e) {
      AppLogger.error('Add monitoring log error', e.toString());
      return false;
    }
  }

  /// Filter logs berdasarkan condition
  List<LogModel> getLogsByCondition(String condition) {
    return _logs.where((log) => log.condition == condition).toList();
  }

  /// Get monitoring logs untuk tanaman tertentu
  List<LogModel> getLogsForPlant(int userPlantId) {
    return _logs.where((log) => log.userPlantId == userPlantId).toList();
  }

  // ============ LOAD ALL ============

  /// Load semua data (care logs + monitoring logs + scan history)
  Future<void> loadAll({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    AppLogger.debug('HistoryProvider: Starting loadAll...');
    
    try {
      // Load care logs
      try {
        AppLogger.debug('HistoryProvider: Loading care logs...');
        _careLogs = await _plantService.getAllCareLogs();
        AppLogger.debug('HistoryProvider: Got ${_careLogs.length} care logs');
      } catch (e) {
        AppLogger.error('HistoryProvider: Care logs failed', e.toString());
        _careLogs = [];
      }
      
      // Load monitoring logs
      try {
        AppLogger.debug('HistoryProvider: Loading monitoring logs...');
        _logs = await _plantService.getAllLogs();
        AppLogger.debug('HistoryProvider: Got ${_logs.length} monitoring logs');
      } catch (e) {
        AppLogger.error('HistoryProvider: Monitoring logs failed', e.toString());
        _logs = [];
      }
      
      // Load scan history
      try {
        AppLogger.debug('HistoryProvider: Loading scan history...');
        _scanHistory = await _scanService.getScanHistory();
        AppLogger.debug('HistoryProvider: Got ${_scanHistory.length} scan history');
      } catch (e) {
        AppLogger.error('HistoryProvider: Scan history failed', e.toString());
        _scanHistory = [];
      }
      
      AppLogger.debug('HistoryProvider: loadAll completed - CareLogs: ${_careLogs.length}, Logs: ${_logs.length}, ScanHistory: ${_scanHistory.length}');
    } catch (e) {
      _errorMessage = 'Gagal memuat history';
      AppLogger.error('HistoryProvider: loadAll general error', e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
