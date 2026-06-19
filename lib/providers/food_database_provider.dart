import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_model.dart';
import '../services/food_database_service.dart';

final foodDatabaseServiceProvider =
    Provider<FoodDatabaseService>((ref) => FoodDatabaseService());



/// All foods (used for random menu and history)
final allFoodsProvider = FutureProvider<List<FoodModel>>((ref) {
  return ref.watch(foodDatabaseServiceProvider).getAllFoods();
});

/// Food search state
class FoodSearchNotifier extends AsyncNotifier<List<FoodModel>> {
  @override
  Future<List<FoodModel>> build() async {
    return ref.watch(foodDatabaseServiceProvider).getAllFoods();
  }

  Future<void> search(String query) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(foodDatabaseServiceProvider).searchFoods(query));
  }

  Future<void> resetToAll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(foodDatabaseServiceProvider).getAllFoods());
  }
}

final foodSearchProvider =
    AsyncNotifierProvider<FoodSearchNotifier, List<FoodModel>>(
        FoodSearchNotifier.new);

/// Random food recommendations based on remaining quota
final randomFoodProvider = FutureProvider.family<List<FoodModel>, ({
  double remainingCalories,
  double remainingProtein,
  double remainingCarbs,
  double remainingFat,
})>((ref, quota) {
  return ref.watch(foodDatabaseServiceProvider).recommendFoods(
        remainingCalories: quota.remainingCalories,
        remainingProtein: quota.remainingProtein,
        remainingCarbs: quota.remainingCarbs,
        remainingFat: quota.remainingFat,
      );
});
