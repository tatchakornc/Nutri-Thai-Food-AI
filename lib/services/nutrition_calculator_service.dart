import '../models/user_model.dart';

/// All nutrition calculation logic — unit-testable pure functions
class NutritionCalculatorService {
  const NutritionCalculatorService._();

  // ─────────────────────────────────────────────
  // BMR — Mifflin-St Jeor Equation
  // ─────────────────────────────────────────────

  /// Calculate Basal Metabolic Rate
  /// Male:   10 × weight(kg) + 6.25 × height(cm) − 5 × age + 5
  /// Female: 10 × weight(kg) + 6.25 × height(cm) − 5 × age − 161
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
  }) {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return gender == Gender.male ? base + 5 : base - 161;
  }

  // ─────────────────────────────────────────────
  // TDEE — Total Daily Energy Expenditure
  // ─────────────────────────────────────────────

  /// Multiply BMR by activity multiplier
  static double calculateTDEE({
    required double bmr,
    required ActivityLevel activityLevel,
  }) {
    return bmr * activityLevel.multiplier;
  }

  // ─────────────────────────────────────────────
  // Daily Calorie Target by Goal
  // ─────────────────────────────────────────────

  /// Adjust TDEE based on user goal
  static double calculateDailyCalorieTarget({
    required double tdee,
    required Goal goal,
  }) {
    switch (goal) {
      case Goal.lose:
        return (tdee - 500).clamp(1200, double.infinity);
      case Goal.maintain:
        return tdee;
      case Goal.gain:
        return tdee + 300;
    }
  }

  // ─────────────────────────────────────────────
  // Macro Targets
  // ─────────────────────────────────────────────

  /// Protein: 1.6–2.2 g per kg body weight
  /// We use 2.0g/kg as a reasonable default
  static double calculateDailyProteinTarget(double weightKg) {
    return weightKg * 2.0;
  }

  /// Fat: 25% of total daily calories (1g fat = 9 kcal)
  static double calculateDailyFatTarget(double dailyCalories) {
    return (dailyCalories * 0.25) / 9;
  }

  /// Carbs: remaining calories after protein and fat (1g carb = 4 kcal)
  static double calculateDailyCarbTarget({
    required double dailyCalories,
    required double proteinGrams,
    required double fatGrams,
  }) {
    final usedCalories = (proteinGrams * 4) + (fatGrams * 9);
    final carbCalories = dailyCalories - usedCalories;
    return (carbCalories / 4).clamp(0, double.infinity);
  }

  // ─────────────────────────────────────────────
  // Remaining Quota
  // ─────────────────────────────────────────────

  static double remainingCalories({
    required double target,
    required double consumed,
  }) => (target - consumed).clamp(0, double.infinity);

  static double remainingProtein({
    required double target,
    required double consumed,
  }) => (target - consumed).clamp(0, double.infinity);

  static double remainingCarbs({
    required double target,
    required double consumed,
  }) => (target - consumed).clamp(0, double.infinity);

  static double remainingFat({
    required double target,
    required double consumed,
  }) => (target - consumed).clamp(0, double.infinity);

  // ─────────────────────────────────────────────
  // Full Profile Calculation
  // ─────────────────────────────────────────────

  /// Compute all daily targets for a user profile and return updated targets
  static NutritionTargets computeTargets({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
    required ActivityLevel activityLevel,
    required Goal goal,
  }) {
    final bmr = calculateBMR(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );
    final tdee = calculateTDEE(bmr: bmr, activityLevel: activityLevel);
    final calories = calculateDailyCalorieTarget(tdee: tdee, goal: goal);
    final protein = calculateDailyProteinTarget(weightKg);
    final fat = calculateDailyFatTarget(calories);
    final carbs = calculateDailyCarbTarget(
      dailyCalories: calories,
      proteinGrams: protein,
      fatGrams: fat,
    );
    return NutritionTargets(
      bmr: bmr,
      tdee: tdee,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }

  // ─────────────────────────────────────────────
  // Gram-based ingredient calculation
  // ─────────────────────────────────────────────

  /// Calculate nutrition for given grams using per-100g values
  static Map<String, double> calculateFromGrams({
    required double grams,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
  }) {
    final ratio = grams / 100;
    return {
      'calories': caloriesPer100g * ratio,
      'protein': proteinPer100g * ratio,
      'carbs': carbsPer100g * ratio,
      'fat': fatPer100g * ratio,
    };
  }
}

/// Result value object for nutrition targets
class NutritionTargets {
  final double bmr;
  final double tdee;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionTargets({
    required this.bmr,
    required this.tdee,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  String toString() =>
      'NutritionTargets(bmr: ${bmr.toStringAsFixed(0)}, tdee: ${tdee.toStringAsFixed(0)}, '
      'calories: ${calories.toStringAsFixed(0)}, protein: ${protein.toStringAsFixed(1)}g, '
      'carbs: ${carbs.toStringAsFixed(1)}g, fat: ${fat.toStringAsFixed(1)}g)';
}
