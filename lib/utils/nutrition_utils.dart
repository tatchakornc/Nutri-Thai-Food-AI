import '../constants/app_colors.dart';
import 'package:flutter/material.dart';

/// UI helpers for displaying nutrition values
class NutritionUtils {
  NutritionUtils._();

  static String formatCalories(double kcal) =>
      '${kcal.toStringAsFixed(0)} kcal';

  static String formatGrams(double g) => '${g.toStringAsFixed(1)} g';

  static double safePercent(double value, double total) {
    if (total <= 0) return 0;
    return (value / total).clamp(0.0, 1.0);
  }

  static Color progressColor(double percent) {
    if (percent < 0.5) return AppColors.primary;
    if (percent < 0.85) return AppColors.yellow;
    if (percent < 1.0) return AppColors.accent;
    return AppColors.error;
  }

  static String macroLabel(String macro, double value) {
    switch (macro) {
      case 'protein': return 'โปรตีน ${value.toStringAsFixed(1)}g';
      case 'carbs': return 'คาร์บ ${value.toStringAsFixed(1)}g';
      case 'fat': return 'ไขมัน ${value.toStringAsFixed(1)}g';
      default: return '${value.toStringAsFixed(1)}g';
    }
  }

  static Color macroColor(String macro) {
    switch (macro) {
      case 'protein': return AppColors.proteinColor;
      case 'carbs': return AppColors.carbColor;
      case 'fat': return AppColors.fatColor;
      default: return AppColors.primary;
    }
  }
}
