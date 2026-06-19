import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/food_model.dart';
import '../models/ingredient_model.dart';

class FoodDatabaseService {
  final FirebaseFirestore _db;

  FoodDatabaseService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _foods =>
      _db.collection('foods');

  CollectionReference<Map<String, dynamic>> get _ingredients =>
      _db.collection('ingredients');

  // ───────────────────────────────────────────────────────────────────────────
  // Foods
  // ───────────────────────────────────────────────────────────────────────────

  Future<List<FoodModel>> searchFoods(String query) async {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      return getAllFoods();
    }

    try {
      final snapshot = await _foods
          .where('nameTh', isGreaterThanOrEqualTo: query.trim())
          .where('nameTh', isLessThanOrEqualTo: '${query.trim()}\uf8ff')
          .limit(20)
          .get();

      final remoteFoods = snapshot.docs
          .map((d) => FoodModel.fromMap(d.data(), d.id))
          .toList();

      if (remoteFoods.isNotEmpty) {
        return remoteFoods;
      }
    } catch (e) {
      print('Search foods from Firestore error: $e');
    }

    return thaiSeedFoods.where((food) {
      return food.nameTh.toLowerCase().contains(q) ||
          food.nameEn.toLowerCase().contains(q) ||
          food.category.toLowerCase().contains(q) ||
          food.tags.any((tag) => tag.toLowerCase().contains(q)) ||
          food.ingredients.any((ing) => ing.toLowerCase().contains(q));
    }).take(20).toList();
  }

  Future<List<FoodModel>> getAllFoods({int limit = 50}) async {
    try {
      final snapshot = await _foods.limit(limit).get();

      final remoteFoods = snapshot.docs
          .map((d) => FoodModel.fromMap(d.data(), d.id))
          .toList();

      if (remoteFoods.isNotEmpty) {
        return remoteFoods;
      }
    } catch (e) {
      print('Get foods from Firestore error: $e');
    }

    return thaiSeedFoods.take(limit).toList();
  }

  Future<FoodModel?> getFoodById(String foodId) async {
    try {
      final doc = await _foods.doc(foodId).get();

      if (doc.exists && doc.data() != null) {
        return FoodModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Get food by id from Firestore error: $e');
    }

    for (final food in thaiSeedFoods) {
      if (food.foodId == foodId) {
        return food;
      }
    }

    return null;
  }

  Future<FoodModel?> matchFoodByName(String rawName) async {
    final q = rawName.trim().toLowerCase();

    if (q.isEmpty) {
      return null;
    }

    final foods = await getAllFoods(limit: 100);

    FoodModel? bestFood;
    var bestScore = 0;

    for (final food in foods) {
      final candidates = [
        food.nameTh,
        food.nameEn,
        food.category,
        ...food.tags,
        ...food.ingredients,
      ].map((x) => x.toLowerCase()).toList();

      for (final candidate in candidates) {
        var score = 0;

        if (candidate == q) {
          score = 100;
        } else if (candidate.contains(q) || q.contains(candidate)) {
          score = 80;
        }

        final qParts = q
            .split(RegExp(r'\s+'))
            .where((part) => part.trim().isNotEmpty)
            .toList();

        for (final part in qParts) {
          if (candidate.contains(part)) {
            score += 10;
          }
        }

        if (score > bestScore) {
          bestScore = score;
          bestFood = food;
        }
      }
    }

    return bestScore >= 20 ? bestFood : null;
  }

  Future<List<FoodModel>> getFoodsByCategory(String category) async {
    final c = category.trim().toLowerCase();

    try {
      final snapshot =
          await _foods.where('category', isEqualTo: category).get();

      final remoteFoods = snapshot.docs
          .map((d) => FoodModel.fromMap(d.data(), d.id))
          .toList();

      if (remoteFoods.isNotEmpty) {
        return remoteFoods;
      }
    } catch (e) {
      print('Get foods by category from Firestore error: $e');
    }

    return thaiSeedFoods.where((food) {
      return food.category.toLowerCase() == c;
    }).toList();
  }

  /// สุ่มเมนูโดยอิงจากโควต้าคงเหลือของวันนี้
  ///
  /// เงื่อนไข:
  /// - calories ต้องไม่เกิน remainingCalories
  /// - protein ต้องไม่เกิน remainingProtein
  /// - carbs ต้องไม่เกิน remainingCarbs
  /// - fat ต้องไม่เกิน remainingFat
  /// - ถ้าไม่มีเมนูที่เข้าเงื่อนไข จะคืน list ว่าง
  /// - ถ้ามีหลายเมนู จะจัดอันดับเมนูที่เหมาะก่อน แล้วสุ่มจากกลุ่มที่เหมาะที่สุด
  Future<List<FoodModel>> recommendFoods({
    required double remainingCalories,
    required double remainingProtein,
    required double remainingCarbs,
    required double remainingFat,
    int limit = 6,
  }) async {
    final allFoods = await getAllFoods(limit: 100);

    final rCalories = _notNegative(remainingCalories);
    final rProtein = _notNegative(remainingProtein);
    final rCarbs = _notNegative(remainingCarbs);
    final rFat = _notNegative(remainingFat);

    if (rCalories <= 0) {
      return [];
    }

    final suitableFoods = allFoods.where((food) {
      return food.calories <= rCalories &&
          food.protein <= rProtein &&
          food.carbs <= rCarbs &&
          food.fat <= rFat;
    }).toList();

    if (suitableFoods.isEmpty) {
      return [];
    }

    suitableFoods.sort((a, b) {
      final scoreA = _recommendScore(
        food: a,
        remainingCalories: rCalories,
        remainingProtein: rProtein,
        remainingCarbs: rCarbs,
        remainingFat: rFat,
      );

      final scoreB = _recommendScore(
        food: b,
        remainingCalories: rCalories,
        remainingProtein: rProtein,
        remainingCarbs: rCarbs,
        remainingFat: rFat,
      );

      return scoreB.compareTo(scoreA);
    });

    final candidateCount = suitableFoods.length < 12 ? suitableFoods.length : 12;
    final candidates = suitableFoods.take(candidateCount).toList();

    candidates.shuffle(Random());

    return candidates.take(limit).toList();
  }

  double _notNegative(double value) {
    return value < 0 ? 0 : value;
  }

  double _recommendScore({
    required FoodModel food,
    required double remainingCalories,
    required double remainingProtein,
    required double remainingCarbs,
    required double remainingFat,
  }) {
    double ratio(double value, double max) {
      if (max <= 0) {
        return 0;
      }

      return value / max;
    }

    final calorieRatio = ratio(food.calories, remainingCalories);
    final proteinRatio = ratio(food.protein, remainingProtein);
    final carbRatio = ratio(food.carbs, remainingCarbs);
    final fatRatio = ratio(food.fat, remainingFat);

    return (calorieRatio * 4) +
        (proteinRatio * 3) +
        (carbRatio * 1.5) +
        (fatRatio * 1.5);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Ingredients
  // ───────────────────────────────────────────────────────────────────────────

  Future<List<IngredientModel>> searchIngredients(String query) async {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      return getAllIngredients();
    }

    try {
      final snapshot = await _ingredients
          .where('nameTh', isGreaterThanOrEqualTo: query.trim())
          .where('nameTh', isLessThanOrEqualTo: '${query.trim()}\uf8ff')
          .limit(20)
          .get();

      final remoteIngredients = snapshot.docs
          .map((d) => IngredientModel.fromMap(d.data(), d.id))
          .toList();

      if (remoteIngredients.isNotEmpty) {
        return remoteIngredients;
      }
    } catch (e) {
      print('Search ingredients from Firestore error: $e');
    }

    return thaiSeedIngredients.where((ingredient) {
      return ingredient.nameTh.toLowerCase().contains(q) ||
          ingredient.nameEn.toLowerCase().contains(q) ||
          ingredient.category.toLowerCase().contains(q) ||
          ingredient.tags.any((tag) => tag.toLowerCase().contains(q));
    }).take(20).toList();
  }

  Future<List<IngredientModel>> getAllIngredients({int limit = 50}) async {
    try {
      final snapshot = await _ingredients.limit(limit).get();

      final remoteIngredients = snapshot.docs
          .map((d) => IngredientModel.fromMap(d.data(), d.id))
          .toList();

      if (remoteIngredients.isNotEmpty) {
        return remoteIngredients;
      }
    } catch (e) {
      print('Get ingredients from Firestore error: $e');
    }

    return thaiSeedIngredients.take(limit).toList();
  }

  Future<IngredientModel?> getIngredientById(String id) async {
    try {
      final doc = await _ingredients.doc(id).get();

      if (doc.exists && doc.data() != null) {
        return IngredientModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Get ingredient by id from Firestore error: $e');
    }

    for (final ingredient in thaiSeedIngredients) {
      if (ingredient.ingredientId == id) {
        return ingredient;
      }
    }

    return null;
  }

  Future<IngredientModel?> matchIngredientByName(String rawName) async {
    final q = rawName.trim().toLowerCase();

    if (q.isEmpty) {
      return null;
    }

    final ingredients = await getAllIngredients(limit: 100);

    IngredientModel? bestIngredient;
    var bestScore = 0;

    for (final ingredient in ingredients) {
      final candidates = [
        ingredient.nameTh,
        ingredient.nameEn,
        ingredient.category,
        ...ingredient.tags,
      ].map((x) => x.toLowerCase()).toList();

      for (final candidate in candidates) {
        var score = 0;

        if (candidate == q) {
          score = 100;
        } else if (candidate.contains(q) || q.contains(candidate)) {
          score = 80;
        }

        final qParts = q
            .split(RegExp(r'\s+'))
            .where((part) => part.trim().isNotEmpty)
            .toList();

        for (final part in qParts) {
          if (candidate.contains(part)) {
            score += 10;
          }
        }

        if (score > bestScore) {
          bestScore = score;
          bestIngredient = ingredient;
        }
      }
    }

    return bestScore >= 20 ? bestIngredient : null;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Seed data
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> seedThaiFoods() async {
    final batch = _db.batch();

    for (final food in thaiSeedFoods) {
      final ref = _foods.doc(food.foodId);
      batch.set(ref, food.toMap());
    }

    await batch.commit();
  }

  Future<void> seedIngredients() async {
    final batch = _db.batch();

    for (final ingredient in thaiSeedIngredients) {
      final ref = _ingredients.doc(ingredient.ingredientId);
      batch.set(ref, ingredient.toMap());
    }

    await batch.commit();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEED DATA — Thai Food Nutrition Database
// ─────────────────────────────────────────────────────────────────────────────

const List<FoodModel> thaiSeedFoods = [
  FoodModel(
    foodId: 'food_001',
    nameTh: 'ข้าวกะเพราไก่ไข่ดาว',
    nameEn: 'Stir-fried Basil Chicken with Rice and Fried Egg',
    category: 'rice_dish',
    servingSize: 400,
    calories: 650,
    protein: 35,
    carbs: 78,
    fat: 22,
    tags: ['ข้าว', 'ไก่', 'ไข่', 'กะเพรา', 'ยอดนิยม'],
  ),
  FoodModel(
    foodId: 'food_002',
    nameTh: 'ข้าวมันไก่',
    nameEn: 'Hainanese Chicken Rice',
    category: 'rice_dish',
    servingSize: 350,
    calories: 520,
    protein: 30,
    carbs: 65,
    fat: 14,
    tags: ['ข้าว', 'ไก่', 'ยอดนิยม'],
  ),
  FoodModel(
    foodId: 'food_003',
    nameTh: 'ส้มตำไทย',
    nameEn: 'Thai Papaya Salad',
    category: 'salad',
    servingSize: 200,
    calories: 130,
    protein: 5,
    carbs: 22,
    fat: 4,
    tags: ['ผัก', 'เผ็ด', 'แคลอรี่ต่ำ'],
  ),
  FoodModel(
    foodId: 'food_004',
    nameTh: 'ต้มยำกุ้ง',
    nameEn: 'Tom Yum Goong',
    category: 'soup',
    servingSize: 300,
    calories: 150,
    protein: 18,
    carbs: 8,
    fat: 6,
    tags: ['ซุป', 'กุ้ง', 'เผ็ด', 'โปรตีนสูง'],
  ),
  FoodModel(
    foodId: 'food_005',
    nameTh: 'ผัดไทย',
    nameEn: 'Pad Thai',
    category: 'noodle',
    servingSize: 350,
    calories: 490,
    protein: 22,
    carbs: 68,
    fat: 15,
    tags: ['เส้น', 'กุ้ง', 'ไข่', 'ยอดนิยม'],
  ),
  FoodModel(
    foodId: 'food_006',
    nameTh: 'ข้าวผัดหมู',
    nameEn: 'Pork Fried Rice',
    category: 'rice_dish',
    servingSize: 350,
    calories: 560,
    protein: 20,
    carbs: 75,
    fat: 18,
    tags: ['ข้าว', 'หมู'],
  ),
  FoodModel(
    foodId: 'food_007',
    nameTh: 'แกงเขียวหวานไก่',
    nameEn: 'Green Curry Chicken',
    category: 'curry',
    servingSize: 250,
    calories: 380,
    protein: 26,
    carbs: 15,
    fat: 24,
    tags: ['แกง', 'ไก่', 'กะทิ'],
  ),
  FoodModel(
    foodId: 'food_008',
    nameTh: 'ไก่ย่าง',
    nameEn: 'Grilled Chicken',
    category: 'grilled',
    servingSize: 200,
    calories: 260,
    protein: 40,
    carbs: 0,
    fat: 10,
    tags: ['ไก่', 'ย่าง', 'โปรตีนสูง', 'คลีน'],
  ),
  FoodModel(
    foodId: 'food_009',
    nameTh: 'ไข่ต้ม',
    nameEn: 'Boiled Egg',
    category: 'egg',
    servingSize: 60,
    calories: 80,
    protein: 6.5,
    carbs: 0.5,
    fat: 5.5,
    tags: ['ไข่', 'โปรตีน'],
  ),
  FoodModel(
    foodId: 'food_010',
    nameTh: 'ข้าวสวย',
    nameEn: 'Steamed Rice',
    category: 'rice',
    servingSize: 180,
    calories: 240,
    protein: 4,
    carbs: 53,
    fat: 0.5,
    tags: ['ข้าว', 'คาร์บ'],
  ),
  FoodModel(
    foodId: 'food_011',
    nameTh: 'อกไก่ย่าง',
    nameEn: 'Grilled Chicken Breast',
    category: 'grilled',
    servingSize: 150,
    calories: 185,
    protein: 37,
    carbs: 0,
    fat: 4,
    tags: ['ไก่', 'คลีน', 'โปรตีนสูง', 'ฟิตเนส'],
  ),
  FoodModel(
    foodId: 'food_012',
    nameTh: 'ไข่ดาว',
    nameEn: 'Fried Egg',
    category: 'egg',
    servingSize: 60,
    calories: 110,
    protein: 7,
    carbs: 0.5,
    fat: 8.5,
    tags: ['ไข่'],
  ),
  FoodModel(
    foodId: 'food_013',
    nameTh: 'หมูปิ้ง',
    nameEn: 'Grilled Pork Skewer',
    category: 'grilled',
    servingSize: 100,
    calories: 200,
    protein: 18,
    carbs: 5,
    fat: 12,
    tags: ['หมู', 'สตรีท'],
  ),
  FoodModel(
    foodId: 'food_014',
    nameTh: 'ก๋วยเตี๋ยวเรือ',
    nameEn: 'Boat Noodle Soup',
    category: 'noodle',
    servingSize: 300,
    calories: 280,
    protein: 20,
    carbs: 35,
    fat: 8,
    tags: ['เส้น', 'ซุป', 'หมู'],
  ),
  FoodModel(
    foodId: 'food_015',
    nameTh: 'ขนมจีนแกงเขียวหวาน',
    nameEn: 'Kanom Jeen with Green Curry',
    category: 'noodle',
    servingSize: 400,
    calories: 440,
    protein: 22,
    carbs: 58,
    fat: 14,
    tags: ['เส้น', 'แกง'],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// SEED DATA — Thai Ingredients per 100g
// ─────────────────────────────────────────────────────────────────────────────

const List<IngredientModel> thaiSeedIngredients = [
  IngredientModel(
    ingredientId: 'ing_001',
    nameTh: 'ข้าวสวยหุง',
    nameEn: 'Cooked White Rice',
    category: 'grain',
    caloriesPer100g: 130,
    proteinPer100g: 2.7,
    carbsPer100g: 28,
    fatPer100g: 0.3,
    tags: ['ข้าว', 'คาร์บ'],
  ),
  IngredientModel(
    ingredientId: 'ing_002',
    nameTh: 'อกไก่สุก',
    nameEn: 'Cooked Chicken Breast',
    category: 'protein',
    caloriesPer100g: 165,
    proteinPer100g: 31,
    carbsPer100g: 0,
    fatPer100g: 3.6,
    tags: ['ไก่', 'โปรตีน', 'คลีน'],
  ),
  IngredientModel(
    ingredientId: 'ing_003',
    nameTh: 'ไข่ดาว',
    nameEn: 'Fried Egg',
    category: 'egg',
    caloriesPer100g: 185,
    proteinPer100g: 13,
    carbsPer100g: 1,
    fatPer100g: 14,
    tags: ['ไข่'],
  ),
  IngredientModel(
    ingredientId: 'ing_004',
    nameTh: 'ไข่ต้ม',
    nameEn: 'Boiled Egg',
    category: 'egg',
    caloriesPer100g: 155,
    proteinPer100g: 13,
    carbsPer100g: 1.1,
    fatPer100g: 10.6,
    tags: ['ไข่'],
  ),
  IngredientModel(
    ingredientId: 'ing_005',
    nameTh: 'หมูสับ',
    nameEn: 'Ground Pork',
    category: 'protein',
    caloriesPer100g: 263,
    proteinPer100g: 17,
    carbsPer100g: 0,
    fatPer100g: 21,
    tags: ['หมู'],
  ),
  IngredientModel(
    ingredientId: 'ing_006',
    nameTh: 'กุ้งสด',
    nameEn: 'Fresh Shrimp',
    category: 'seafood',
    caloriesPer100g: 99,
    proteinPer100g: 24,
    carbsPer100g: 0.2,
    fatPer100g: 0.3,
    tags: ['กุ้ง', 'โปรตีน', 'แคลอรี่ต่ำ'],
  ),
  IngredientModel(
    ingredientId: 'ing_007',
    nameTh: 'เส้นก๋วยเตี๋ยวสุก',
    nameEn: 'Cooked Rice Noodles',
    category: 'grain',
    caloriesPer100g: 109,
    proteinPer100g: 1.8,
    carbsPer100g: 25,
    fatPer100g: 0.2,
    tags: ['เส้น', 'คาร์บ'],
  ),
  IngredientModel(
    ingredientId: 'ing_008',
    nameTh: 'น้ำมันพืช',
    nameEn: 'Vegetable Oil',
    category: 'fat',
    caloriesPer100g: 884,
    proteinPer100g: 0,
    carbsPer100g: 0,
    fatPer100g: 100,
    tags: ['ไขมัน'],
  ),
  IngredientModel(
    ingredientId: 'ing_009',
    nameTh: 'กะทิ',
    nameEn: 'Coconut Milk',
    category: 'fat',
    caloriesPer100g: 230,
    proteinPer100g: 2.3,
    carbsPer100g: 5.5,
    fatPer100g: 24,
    tags: ['กะทิ', 'ไขมัน'],
  ),
  IngredientModel(
    ingredientId: 'ing_010',
    nameTh: 'มะละกอดิบ',
    nameEn: 'Green Papaya',
    category: 'vegetable',
    caloriesPer100g: 27,
    proteinPer100g: 0.5,
    carbsPer100g: 6.9,
    fatPer100g: 0.1,
    tags: ['ผัก', 'แคลอรี่ต่ำ'],
  ),
];