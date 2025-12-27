import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget untuk search bar yang dapat di-reuse
/// 
/// Penggunaan:
/// ```dart
/// SearchBarWidget(
///   hintText: 'Cari tanaman...',
///   onChanged: (value) => print(value),
///   onFilterTap: () => showFilterDialog(),
/// )
/// ```
class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final TextEditingController? controller;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Cari tanaman...',
    this.onChanged,
    this.onFilterTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontSize: 14,
          ),
          filled: true,
          fillColor: AppColors.surface,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 12),
            child: Icon(Icons.search, color: AppColors.primary, size: 24),
          ),
          suffixIcon: onFilterTap != null
              ? GestureDetector(
                  onTap: onFilterTap,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.tune, color: AppColors.textHint, size: 20),
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
