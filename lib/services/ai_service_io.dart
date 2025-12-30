import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class AIService {
  Interpreter? _interpreter;
  static const String modelFile = "assets/TanamCareModelAI.tflite";
  static const int inputSize = 224;

  Future<void> loadModel() async {
    try {
      // OPSI TAMBAHAN: Gunakan InterpreterOptions untuk kompatibilitas
      final options = InterpreterOptions();

      // Jika di Android, kadang menonaktifkan atau mengatur thread membantu
      options.threads = 1;
      // options.addDelegate(XNNPackDelegate()); // Coba aktifkan/matikan ini jika perlu

      // Load Model dengan Options
      _interpreter = await Interpreter.fromAsset(modelFile, options: options);
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // ... (Bagian analyzeImage dan close TETAP SAMA seperti sebelumnya)
  Future<Map<String, dynamic>?> analyzeImage(
      File imageFile, List<String> labels) async {
    if (_interpreter == null) {
      await loadModel();
      if (_interpreter == null) return null;
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      final resizedImage =
          img.copyResize(image, width: inputSize, height: inputSize);

      var input = List.generate(
          1,
          (i) => List.generate(inputSize,
              (j) => List.generate(inputSize, (k) => List.filled(3, 0.0))));

      for (var y = 0; y < inputSize; y++) {
        for (var x = 0; x < inputSize; x++) {
          final pixel = resizedImage.getPixel(x, y);
          input[0][y][x][0] = pixel.r / 255.0;
          input[0][y][x][1] = pixel.g / 255.0;
          input[0][y][x][2] = pixel.b / 255.0;
        }
      }

      var output =
          List.filled(1 * labels.length, 0.0).reshape([1, labels.length]);

      _interpreter!.run(input, output);

      List<double> result = List<double>.from(output[0]);
      double maxScore = 0.0;
      int maxIndex = 0;

      for (int i = 0; i < result.length; i++) {
        if (result[i] > maxScore) {
          maxScore = result[i];
          maxIndex = i;
        }
      }

      if (maxIndex >= labels.length) {
        return {'label': "Unknown", 'confidence': "0.0", 'index': -1};
      }

      return {
        'label': labels[maxIndex],
        'confidence': (maxScore * 100).toStringAsFixed(1),
        'index': maxIndex
      };
    } catch (e) {
      print("Error during inference: $e");
      return null;
    }
  }

  void close() {
    _interpreter?.close();
  }
}
