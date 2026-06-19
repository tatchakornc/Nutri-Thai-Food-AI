import 'package:cloud_firestore/cloud_firestore.dart';

/// Thai food item from the nutrition database
class FoodModel {
  final String foodId;
  final String nameTh;
  final String nameEn;
  final String category;
  final double servingSize; // in grams
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> tags;

  const FoodModel({
    required this.foodId,
    required this.nameTh,
    required this.nameEn,
    required this.category,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imageUrl = '',
    this.ingredients = const [],
    this.tags = const [],
  });

  factory FoodModel.fromMap(Map<String, dynamic> map, String docId) {
    return FoodModel(
      foodId: docId,
      nameTh: map['nameTh'] as String? ?? '',
      nameEn: map['nameEn'] as String? ?? '',
      category: map['category'] as String? ?? '',
      servingSize: (map['servingSize'] as num?)?.toDouble() ?? 100,
      calories: (map['calories'] as num?)?.toDouble() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0,
      imageUrl: map['imageUrl'] as String? ?? '',
      ingredients: List<String>.from(map['ingredients'] as List? ?? []),
      tags: List<String>.from(map['tags'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'nameTh': nameTh,
      'nameEn': nameEn,
      'category': category,
      'servingSize': servingSize,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'tags': tags,
    };
  }

  /// Scale nutrition by multiplying serving ratio
  FoodModel scaleBy(double grams) {
    final ratio = grams / servingSize;
    return FoodModel(
      foodId: foodId,
      nameTh: nameTh,
      nameEn: nameEn,
      category: category,
      servingSize: grams,
      calories: calories * ratio,
      protein: protein * ratio,
      carbs: carbs * ratio,
      fat: fat * ratio,
      imageUrl: imageUrl,
      ingredients: ingredients,
      tags: tags,
    );
  }
}
