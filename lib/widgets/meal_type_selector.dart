import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/food_log_model.dart';

class MealTypeSelector extends StatelessWidget {
  final MealType selected;
  final ValueChanged<MealType> onChanged;

  const MealTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: MealType.values.map((type) {
        final isSelected = selected == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    type.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.label.replaceAll('มื้อ', '').trim(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
