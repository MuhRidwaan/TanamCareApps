import 'dart:async';

/// Web stub for AIService: TFLite (dart:ffi) is not supported on Web.
/// This stub provides the same API surface but no-op implementations so the
/// application can still compile and run on the web platform.
class AIService {
  AIService();

  /// No-op on web.
  Future<void> loadModel() async {
    // Optionally, you could initialize a TF.js bridge here in the future.
    print('AIService.loadModel(): Not supported on Web.');
    return;
  }

  /// Returns null on web to indicate analysis is not available.
  Future<Map<String, dynamic>?> analyzeImage(
      dynamic imageFile, List<String> labels) async {
    print('AIService.analyzeImage(): Not supported on Web.');
    return null;
  }

  void close() {
    // Nothing to close on web.
  }
}
