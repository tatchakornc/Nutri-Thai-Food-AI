import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_log_model.dart';
import '../services/food_log_service.dart';
import '../services/streak_service.dart';
import '../services/quest_service.dart';
import '../utils/date_utils.dart' as appDate;
import 'auth_provider.dart';
import 'water_provider.dart';
import 'user_provider.dart';

final foodLogServiceProvider =
    Provider<FoodLogService>((ref) => FoodLogService());

final streakServiceProvider =
    Provider<StreakService>((ref) => StreakService());

final questServiceProvider =
    Provider<QuestService>((ref) => QuestService());

/// Today's food logs (live stream)
final todayFoodLogsProvider = StreamProvider<List<FoodLogModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref
      .watch(foodLogServiceProvider)
      .streamLogsForDate(user.uid, appDate.DateUtils.todayString());
});

/// Today's total nutrition summary
final todayNutritionProvider = Provider<({
  double calories,
  double protein,
  double carbs,
  double fat
})>((ref) {
  final logs = ref.watch(todayFoodLogsProvider).valueOrNull ?? [];
  return FoodLogService.sumNutrition(logs);
});

/// Meal type coverage for today
final loggedMealTypesProvider = Provider<Set<MealType>>((ref) {
  final logs = ref.watch(todayFoodLogsProvider).valueOrNull ?? [];
  return FoodLogService.loggedMealTypes(logs);
});

/// Recent logs for history
final recentFoodLogsProvider = FutureProvider<List<FoodLogModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(foodLogServiceProvider).getRecentLogs(user.uid);
});

class FoodLogNotifier extends AsyncNotifier<void> {
  late FoodLogService _logService;
  late StreakService _streakService;

  @override
  Future<void> build() async {
    _logService = ref.watch(foodLogServiceProvider);
    _streakService = ref.watch(streakServiceProvider);
  }

  Future<void> addLog(FoodLogModel log) async {
    state = const AsyncLoading();
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }
    state = await AsyncValue.guard(() async {
      await _logService.addFoodLog(user.uid, log);
      // Update streak after adding a log
      await _streakService.updateStreak(user.uid);
      // Update quests
      await _updateQuests(user.uid);
    });
  }

  Future<void> deleteLog(String logId) async {
    state = const AsyncLoading();
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    state = await AsyncValue.guard(
        () => _logService.deleteFoodLog(user.uid, logId));
  }

  Future<void> _updateQuests(String uid) async {
    final questService = ref.read(questServiceProvider);
    final profile = ref.read(userProfileProvider).valueOrNull;
    final logs = ref.read(todayFoodLogsProvider).valueOrNull ?? [];
    final waterLog = ref.read(todayWaterLogProvider).valueOrNull;
    if (profile == null || waterLog == null) return;
    await questService.updateQuestProgress(
      userId: uid,
      todayLogs: logs,
      waterLog: waterLog,
      calorieTarget: profile.dailyCalorieTarget,
      proteinTarget: profile.dailyProteinTarget,
    );
  }
}

final foodLogNotifierProvider =
    AsyncNotifierProvider<FoodLogNotifier, void>(FoodLogNotifier.new);
