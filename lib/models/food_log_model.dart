import 'package:cloud_firestore/cloud_firestore.dart';

enum MealType {
  breakfast('breakfast', 'มื้อเช้า', '🌅'),
  lunch('lunch', 'มื้อกลางวัน', '☀️'),
  dinner('dinner', 'มื้อเย็น', '🌙'),
  snack('snack', 'ของว่าง', '🍎');

  const MealType(this.value, this.label, this.emoji);
  final String value;
  final String label;
  final String emoji;
}

enum FoodLogSourceType {
  aiScan('ai_scan', 'สแกน AI'),
  history('history', 'ประวัติ'),
  quickManual('quick_manual', 'บันทึกด่วน'),
  gramBased('gram_based', 'คำนวณกรัม');

  const FoodLogSourceType(this.value, this.label);
  final String value;
  final String label;
}

/// A component for gram-based food log calculation
class FoodComponent {
  final String componentName;
  final double grams;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double calculatedCalories;
  final double calculatedProtein;
  final double calculatedCarbs;
  final double calculatedFat;

  const FoodComponent({
    required this.componentName,
    required this.grams,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.calculatedCalories,
    required this.calculatedProtein,
    required this.calculatedCarbs,
    required this.calculatedFat,
  });

  factory FoodComponent.fromMap(Map<String, dynamic> map) {
    return FoodComponent(
      componentName: map['componentName'] as String? ?? '',
      grams: (map['grams'] as num?)?.toDouble() ?? 0,
      caloriesPer100g: (map['caloriesPer100g'] as num?)?.toDouble() ?? 0,
      proteinPer100g: (map['proteinPer100g'] as num?)?.toDouble() ?? 0,
      carbsPer100g: (map['carbsPer100g'] as num?)?.toDouble() ?? 0,
      fatPer100g: (map['fatPer100g'] as num?)?.toDouble() ?? 0,
      calculatedCalories: (map['calculatedCalories'] as num?)?.toDouble() ?? 0,
      calculatedProtein: (map['calculatedProtein'] as num?)?.toDouble() ?? 0,
      calculatedCarbs: (map['calculatedCarbs'] as num?)?.toDouble() ?? 0,
      calculatedFat: (map['calculatedFat'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'componentName': componentName,
        'grams': grams,
        'caloriesPer100g': caloriesPer100g,
        'proteinPer100g': proteinPer100g,
        'carbsPer100g': carbsPer100g,
        'fatPer100g': fatPer100g,
        'calculatedCalories': calculatedCalories,
        'calculatedProtein': calculatedProtein,
        'calculatedCarbs': calculatedCarbs,
        'calculatedFat': calculatedFat,
      };

  /// Factory: compute values from per-100g data
  factory FoodComponent.calculate({
    required String componentName,
    required double grams,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
  }) {
    final ratio = grams / 100;
    return FoodComponent(
      componentName: componentName,
      grams: grams,
      caloriesPer100g: caloriesPer100g,
      proteinPer100g: proteinPer100g,
      carbsPer100g: carbsPer100g,
      fatPer100g: fatPer100g,
      calculatedCalories: caloriesPer100g * ratio,
      calculatedProtein: proteinPer100g * ratio,
      calculatedCarbs: carbsPer100g * ratio,
      calculatedFat: fatPer100g * ratio,
    );
  }
}

class FoodLogModel {
  final String logId;
  final String userId;
  final DateTime date;
  final MealType mealType;
  final String foodName;
  final FoodLogSourceType sourceType;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String imageUrl;
  final List<FoodComponent> components;
  final String notes;
  final DateTime createdAt;

  const FoodLogModel({
    required this.logId,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foodName,
    required this.sourceType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imageUrl = '',
    this.components = const [],
    this.notes = '',
    required this.createdAt,
  });

  factory FoodLogModel.fromMap(Map<String, dynamic> map, String docId) {
    return FoodLogModel(
      logId: docId,
      userId: map['userId'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mealType: MealType.values.firstWhere(
        (m) => m.value == map['mealType'],
        orElse: () => MealType.snack,
      ),
      foodName: map['foodName'] as String? ?? '',
      sourceType: FoodLogSourceType.values.firstWhere(
        (s) => s.value == map['sourceType'],
        orElse: () => FoodLogSourceType.quickManual,
      ),
      calories: (map['calories'] as num?)?.toDouble() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0,
      imageUrl: map['imageUrl'] as String? ?? '',
      components: (map['components'] as List<dynamic>? ?? [])
          .map((c) => FoodComponent.fromMap(c as Map<String, dynamic>))
          .toList(),
      notes: map['notes'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'mealType': mealType.value,
      'foodName': foodName,
      'sourceType': sourceType.value,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'imageUrl': imageUrl,
      'components': components.map((c) => c.toMap()).toList(),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Summarize total nutrition from components (for gram-based logs)
  static FoodLogModel fromComponents({
    required String logId,
    required String userId,
    required DateTime date,
    required MealType mealType,
    required String foodName,
    required List<FoodComponent> components,
    required String imageUrl,
    required String notes,
  }) {
    final totalCalories = components.fold(0.0, (s, c) => s + c.calculatedCalories);
    final totalProtein = components.fold(0.0, (s, c) => s + c.calculatedProtein);
    final totalCarbs = components.fold(0.0, (s, c) => s + c.calculatedCarbs);
    final totalFat = components.fold(0.0, (s, c) => s + c.calculatedFat);
    return FoodLogModel(
      logId: logId,
      userId: userId,
      date: date,
      mealType: mealType,
      foodName: foodName,
      sourceType: FoodLogSourceType.gramBased,
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      imageUrl: imageUrl,
      components: components,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }
}
