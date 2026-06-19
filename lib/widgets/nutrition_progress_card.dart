import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'macro_progress_bar.dart';

/// Large daily calorie + macro progress card for the dashboard
class NutritionProgressCard extends StatelessWidget {
  final double caloriesConsumed;
  final double caloriesTarget;
  final double proteinConsumed;
  final double proteinTarget;
  final double carbsConsumed;
  final double carbsTarget;
  final double fatConsumed;
  final double fatTarget;

  const NutritionProgressCard({
    super.key,
    required this.caloriesConsumed,
    required this.caloriesTarget,
    required this.proteinConsumed,
    required this.proteinTarget,
    required this.carbsConsumed,
    required this.carbsTarget,
    required this.fatConsumed,
    required this.fatTarget,
  });

  double get _calPercent =>
      caloriesTarget > 0
          ? (caloriesConsumed / caloriesTarget).clamp(0.0, 1.0)
          : 0;

  double get _caloriesRemaining =>
      (caloriesTarget - caloriesConsumed).clamp(0, double.infinity);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calories row
          Row(
            children: [
              // Circular progress
              _CalorieRing(percent: _calPercent),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'แคลอรี่วันนี้',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${caloriesConsumed.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'จาก ${caloriesTarget.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'เหลือ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_caloriesRemaining.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  const Text(
                    'kcal',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // Macros
          MacroProgressBar(
            label: 'โปรตีน',
            consumed: proteinConsumed,
            target: proteinTarget,
            color: AppColors.proteinColor,
          ),
          const SizedBox(height: 12),
          MacroProgressBar(
            label: 'คาร์บ',
            consumed: carbsConsumed,
            target: carbsTarget,
            color: AppColors.carbColor,
          ),
          const SizedBox(height: 12),
          MacroProgressBar(
            label: 'ไขมัน',
            consumed: fatConsumed,
            target: fatTarget,
            color: AppColors.fatColor,
          ),
        ],
      ),
    );
  }
}

class _CalorieRing extends StatelessWidget {
  final double percent;
  const _CalorieRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: percent,
              backgroundColor: AppColors.calorieColor.withOpacity(0.12),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.calorieColor),
              strokeWidth: 7,
            ),
          ),
          Text(
            '${(percent * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.calorieColor,
            ),
          ),
        ],
      ),
    );
  }
}
