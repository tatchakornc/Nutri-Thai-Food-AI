import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../constants/app_colors.dart';
import '../../models/food_log_model.dart';
import '../../models/food_model.dart';
import '../../providers/food_database_provider.dart';
import '../../providers/food_log_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/nutrition_calculator_service.dart';
import '../../utils/date_utils.dart' as appDate;
import '../../widgets/loading_view.dart';
import '../../widgets/meal_type_selector.dart';
import '../../widgets/primary_button.dart';

class RandomFoodScreen extends ConsumerStatefulWidget {
  const RandomFoodScreen({super.key});

  @override
  ConsumerState<RandomFoodScreen> createState() => _RandomFoodScreenState();
}

class _RandomFoodScreenState extends ConsumerState<RandomFoodScreen> {
  MealType _mealType = MealType.lunch;
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final nutrition = ref.watch(todayNutritionProvider);

    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('กรุณาตั้งค่าโปรไฟล์ก่อน')),
      );
    }

    final remaining = (
      remainingCalories: NutritionCalculatorService.remainingCalories(
        target: profile.dailyCalorieTarget,
        consumed: nutrition.calories,
      ),
      remainingProtein: NutritionCalculatorService.remainingProtein(
        target: profile.dailyProteinTarget,
        consumed: nutrition.protein,
      ),
      remainingCarbs: NutritionCalculatorService.remainingCarbs(
        target: profile.dailyCarbTarget,
        consumed: nutrition.carbs,
      ),
      remainingFat: NutritionCalculatorService.remainingFat(
        target: profile.dailyFatTarget,
        consumed: nutrition.fat,
      ),
    );

    final randomAsync = ref.watch(randomFoodProvider(remaining));

    return Scaffold(
      appBar: AppBar(title: const Text('สุ่มเมนูแนะนำ')),
      body: Column(
        children: [
          // Remaining quota banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primarySurface, Color(0xFFF0FAF4)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'โควต้าคงเหลือวันนี้',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QuotaChip(
                      label: 'แคลอรี่',
                      value: '${remaining.remainingCalories.toStringAsFixed(0)}',
                      unit: 'kcal',
                      color: AppColors.calorieColor,
                    ),
                    _QuotaChip(
                      label: 'โปรตีน',
                      value: '${remaining.remainingProtein.toStringAsFixed(1)}',
                      unit: 'g',
                      color: AppColors.proteinColor,
                    ),
                    _QuotaChip(
                      label: 'คาร์บ',
                      value: '${remaining.remainingCarbs.toStringAsFixed(1)}',
                      unit: 'g',
                      color: AppColors.carbColor,
                    ),
                    _QuotaChip(
                      label: 'ไขมัน',
                      value: '${remaining.remainingFat.toStringAsFixed(1)}',
                      unit: 'g',
                      color: AppColors.fatColor,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Meal selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MealTypeSelector(
              selected: _mealType,
              onChanged: (m) => setState(() => _mealType = m),
            ),
          ),
          const SizedBox(height: 12),

          // Food list
          Expanded(
            child: randomAsync.when(
              loading: () =>
                  const LoadingView(message: 'กำลังค้นหาเมนูที่เหมาะสม...'),
              error: (e, _) => Center(child: Text('$e')),
              data: (foods) {
                if (foods.isEmpty) {
                  return const Center(
                    child: Text(
                      'ไม่พบเมนูที่เหมาะสม\nลองเพิ่มข้อมูลโภชนาการ',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: foods.length,
                  itemBuilder: (ctx, i) => _FoodRecommendCard(
                    food: foods[i],
                    onSave: () => _saveFood(foods[i]),
                  ),
                );
              },
            ),
          ),

          // Refresh button
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              label: '🎲  สุ่มใหม่',
              variant: PrimaryButtonVariant.outlined,
              onPressed: () => ref.invalidate(randomFoodProvider(remaining)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveFood(FoodModel food) async {
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile == null) return;

    final log = FoodLogModel(
      logId: _uuid.v4(),
      userId: profile.uid,
      date: DateTime.parse(appDate.DateUtils.todayString()),
      mealType: _mealType,
      foodName: food.nameTh,
      sourceType: FoodLogSourceType.history,
      calories: food.calories,
      protein: food.protein,
      carbs: food.carbs,
      fat: food.fat,
      imageUrl: food.imageUrl,
      createdAt: DateTime.now(),
    );

    await ref.read(foodLogNotifierProvider.notifier).addLog(log);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึก "${food.nameTh}" สำเร็จ!')),
      );
    }
  }
}

class _FoodRecommendCard extends StatelessWidget {
  final FoodModel food;
  final VoidCallback onSave;
  const _FoodRecommendCard({required this.food, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.accent.withOpacity(0.1),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Center(
              child: food.imageUrl.isEmpty
                  ? const Text('🍽️', style: TextStyle(fontSize: 52))
                  : Image.network(food.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.nameTh,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (food.nameEn.isNotEmpty)
                  Text(
                    food.nameEn,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _MacroBadge(
                      label: '${food.calories.toStringAsFixed(0)} kcal',
                      color: AppColors.calorieColor,
                    ),
                    const SizedBox(width: 6),
                    _MacroBadge(
                      label: 'P ${food.protein.toStringAsFixed(1)}g',
                      color: AppColors.proteinColor,
                    ),
                    const SizedBox(width: 6),
                    _MacroBadge(
                      label: 'C ${food.carbs.toStringAsFixed(1)}g',
                      color: AppColors.carbColor,
                    ),
                    const SizedBox(width: 6),
                    _MacroBadge(
                      label: 'F ${food.fat.toStringAsFixed(1)}g',
                      color: AppColors.fatColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        size: 18),
                    label: const Text('บันทึกเมนูนี้'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _MacroBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _QuotaChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  const _QuotaChip(
      {required this.label,
      required this.value,
      required this.unit,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 10, color: AppColors.textHint),
        ),
        Text(
          label,
          style:
              const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
