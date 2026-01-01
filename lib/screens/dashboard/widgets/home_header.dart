import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import 'weather_card.dart';

/// Header widget dengan greeting dan cuaca
class HomeHeader extends StatelessWidget {
  final UserModel? user;
  final Future<Map<String, dynamic>> weatherFuture;

  const HomeHeader({
    super.key,
    required this.user,
    required this.weatherFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1), // ✅ Pakai withOpacity
            AppColors.primaryDark.withOpacity(0.05), // ✅ Pakai withOpacity
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Haii, ${user?.name ?? 'Petani'}! 👋",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Siap Menanam Hari Ini 🌱",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          WeatherCard(weatherFuture: weatherFuture),
        ],
      ),
    );
  }
}
