import 'package:dio/dio.dart';

class WeatherService {
  final Dio _dio = Dio();

  // Mengambil cuaca berdasarkan lokasi (Default: Jakarta jika null)
  Future<Map<String, dynamic>> getCurrentWeather(
      {double? lat, double? long}) async {
    // Default Jakarta: -6.2088, 106.8456
    final double latitude = lat ?? -6.2088;
    final double longitude = long ?? 106.8456;

    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true';

    try {
      final response = await _dio.get(url);
      return response.data['current_weather'];
    } catch (e) {
      print("Weather Error: $e");
      return {}; // Return kosong jika gagal
    }
  }
}
