import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/food_log_model.dart';

class FoodLogCard extends StatelessWidget {
  final FoodLogModel log;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const FoodLogCard({
    super.key,
    required this.log,
    this.onDelete,
    this.onTap,
  });

  Color get _mealColor {
    switch (log.mealType) {
      case MealType.breakfast: return AppColors.breakfastColor;
      case MealType.lunch: return AppColors.lunchColor;
      case MealType.dinner: return AppColors.dinnerColor;
      case MealType.snack: return AppColors.snackColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            // Meal type indicator
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _mealColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  log.mealType.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.foodName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MacroChip(
                        label: '${log.calories.toStringAsFixed(0)} kcal',
                        color: AppColors.calorieColor,
                      ),
                      const SizedBox(width: 4),
                      _MacroChip(
                        label: 'P ${log.protein.toStringAsFixed(1)}g',
                        color: AppColors.proteinColor,
                      ),
                      const SizedBox(width: 4),
                      _MacroChip(
                        label: 'C ${log.carbs.toStringAsFixed(1)}g',
                        color: AppColors.carbColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.textHint, size: 20),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MacroChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
