import 'dart:io';
import 'package:flutter/material.dart';
import '../services/scan_service.dart';
import '../models/scan_result_model.dart';
import '../core/utils/app_logger.dart';

/// Provider untuk History Scan AI
/// Sesuai dokumentasi API:
/// GET /scans?user_plant_id={id}
/// POST /scans - Body: user_plant_id, detected_issue_id (nullable), confidence_score, image_path
class ScanProvider extends ChangeNotifier {
  final ScanService _scanService = ScanService();

  List<ScanResultModel> _scanHistory = [];
  List<ScanResultModel> get scanHistory => _scanHistory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ScanResultModel? _lastScanResult;
  ScanResultModel? get lastScanResult => _lastScanResult;

  /// Load scan history dari API
  /// GET /scans
  Future<void> loadScanHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _scanHistory = await _scanService.getScanHistory();
      AppLogger.debug('Loaded ${_scanHistory.length} scan history');
    } catch (e) {
      _errorMessage = 'Gagal memuat history scan';
      AppLogger.error('Load scan history error', e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Simpan hasil scan ke database
  /// POST /scans
  /// Body: user_plant_id, detected_issue_id (nullable), confidence_score, image_path (string)
  Future<bool> saveScanResult({
    required int userPlantId,
    int? detectedIssueId,
    required double confidenceScore,
    File? imageFile,
    String? detectedLabel,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _scanService.saveScanResult(
        userPlantId: userPlantId,
        detectedIssueId: detectedIssueId,
        confidenceScore: confidenceScore,
        imageFile: imageFile,
        detectedLabel: detectedLabel,
      );

      if (result['success'] == true) {
        // Refresh history
        await loadScanHistory();
        
        AppLogger.debug('Scan result saved successfully');
        _isSaving = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isSaving = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Gagal menyimpan hasil scan';
      AppLogger.error('Save scan result error', e.toString());
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Hapus scan result
  Future<bool> deleteScanResult(int id) async {
    try {
      final success = await _scanService.deleteScanResult(id);
      if (success) {
        _scanHistory.removeWhere((scan) => scan.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      AppLogger.error('Delete scan result error', e.toString());
      return false;
    }
  }

  /// Get scan results by plant (dari cache lokal)
  List<ScanResultModel> getScansByPlant(int userPlantId) {
    return _scanHistory.where((scan) => scan.userPlantId == userPlantId).toList();
  }

  /// Load scans by plant dari API
  /// GET /scans?user_plant_id={id}
  Future<List<ScanResultModel>> loadScansByPlantId(int userPlantId) async {
    try {
      return await _scanService.getScansByPlantId(userPlantId);
    } catch (e) {
      AppLogger.error('Load scans by plant error', e.toString());
      return [];
    }
  }

  /// Get recent scans (limit)
  List<ScanResultModel> getRecentScans({int limit = 5}) {
    final sorted = List<ScanResultModel>.from(_scanHistory);
    // Sort by createdAt if available
    sorted.sort((a, b) {
      final aDate = a.createdAt ?? '';
      final bDate = b.createdAt ?? '';
      return bDate.compareTo(aDate);
    });
    return sorted.take(limit).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
