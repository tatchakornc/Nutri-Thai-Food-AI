import 'package:cloud_firestore/cloud_firestore.dart';

/// Thai ingredient — nutrition values per 100g
class IngredientModel {
  final String ingredientId;
  final String nameTh;
  final String nameEn;
  final String category;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final List<String> tags;

  const IngredientModel({
    required this.ingredientId,
    required this.nameTh,
    required this.nameEn,
    required this.category,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.tags = const [],
  });

  factory IngredientModel.fromMap(Map<String, dynamic> map, String docId) {
    return IngredientModel(
      ingredientId: docId,
      nameTh: map['nameTh'] as String? ?? '',
      nameEn: map['nameEn'] as String? ?? '',
      category: map['category'] as String? ?? '',
      caloriesPer100g: (map['caloriesPer100g'] as num?)?.toDouble() ?? 0,
      proteinPer100g: (map['proteinPer100g'] as num?)?.toDouble() ?? 0,
      carbsPer100g: (map['carbsPer100g'] as num?)?.toDouble() ?? 0,
      fatPer100g: (map['fatPer100g'] as num?)?.toDouble() ?? 0,
      tags: List<String>.from(map['tags'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'ingredientId': ingredientId,
        'nameTh': nameTh,
        'nameEn': nameEn,
        'category': category,
        'caloriesPer100g': caloriesPer100g,
        'proteinPer100g': proteinPer100g,
        'carbsPer100g': carbsPer100g,
        'fatPer100g': fatPer100g,
        'tags': tags,
      };

  /// Calculate nutrition for a given number of grams
  Map<String, double> nutritionForGrams(double grams) {
    final ratio = grams / 100;
    return {
      'calories': caloriesPer100g * ratio,
      'protein': proteinPer100g * ratio,
      'carbs': carbsPer100g * ratio,
      'fat': fatPer100g * ratio,
    };
  }
}
