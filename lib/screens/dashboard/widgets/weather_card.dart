import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget untuk weather card di header
///
/// Penggunaan:
/// ```dart
/// WeatherCard(
///   weatherFuture: weatherService.getCurrentWeather(),
/// )
/// ```
class WeatherCard extends StatelessWidget {
  final Future<Map<String, dynamic>> weatherFuture;

  const WeatherCard({
    super.key,
    required this.weatherFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 50,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Icon(
              Icons.error_outline,
              color: AppColors.textHint,
              size: 24,
            );
          }

          final temp = snapshot.data?['temperature'] ?? 0;
          final condition = snapshot.data?['condition'] ?? 'sunny';

          return Row(
            children: [
              Icon(
                _getWeatherIcon(condition),
                color: _getWeatherColor(condition),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "$temp°",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'cloudy':
      case 'partly cloudy':
        return Icons.cloud;
      case 'rainy':
      case 'rain':
        return Icons.water_drop;
      case 'stormy':
      case 'thunderstorm':
        return Icons.thunderstorm;
      default:
        return Icons.wb_sunny;
    }
  }

  Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Colors.orange;
      case 'cloudy':
      case 'partly cloudy':
        return Colors.grey;
      case 'rainy':
      case 'rain':
        return Colors.blue;
      case 'stormy':
      case 'thunderstorm':
        return Colors.deepPurple;
      default:
        return Colors.orange;
    }
  }
}
