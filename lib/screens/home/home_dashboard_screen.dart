import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../models/food_log_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_log_provider.dart';
import '../../providers/quest_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/water_provider.dart';
import '../../utils/date_utils.dart' as appDate;
import '../../widgets/food_log_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/nutrition_progress_card.dart';
import '../../widgets/quest_card.dart';
import '../../widgets/streak_fire_widget.dart';
import '../../widgets/water_glass_grid.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final logsAsync = ref.watch(todayFoodLogsProvider);
    final nutrition = ref.watch(todayNutritionProvider);
    final waterAsync = ref.watch(todayWaterLogProvider);
    final streakAsync = ref.watch(streakProvider);
    final questsAsync = ref.watch(todayQuestsProvider);
    final loggedMeals = ref.watch(loggedMealTypesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('กรุณาตั้งค่าโปรไฟล์'));
          }
          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 100,
                floating: true,
                pinned: false,
                backgroundColor: AppColors.background,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${appDate.DateUtils.greeting()},',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    profile.displayName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            streakAsync.when(
                              data: (s) => StreakFireWidget(
                                  streak: s, compact: true),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Nutrition card
                    NutritionProgressCard(
                      caloriesConsumed: nutrition.calories,
                      caloriesTarget: profile.dailyCalorieTarget,
                      proteinConsumed: nutrition.protein,
                      proteinTarget: profile.dailyProteinTarget,
                      carbsConsumed: nutrition.carbs,
                      carbsTarget: profile.dailyCarbTarget,
                      fatConsumed: nutrition.fat,
                      fatTarget: profile.dailyFatTarget,
                    ),
                    const SizedBox(height: 16),

                    // Meal completion notice
                    _MealCompletionBanner(loggedMeals: loggedMeals),

                    // Quick Actions
                    const SizedBox(height: 16),
                    _QuickActionsRow(),

                    const SizedBox(height: 16),

                    // Water tracker
                    waterAsync.when(
                      data: (wl) => WaterGlassGrid(
                        waterLog: wl,
                        onAddGlass: () =>
                            ref.read(waterNotifierProvider.notifier).addGlass(),
                        onRemoveGlass: () => ref
                            .read(waterNotifierProvider.notifier)
                            .removeGlass(),
                      ),
                      loading: () => const LoadingView(),
                      error: (e, _) => Text('$e'),
                    ),

                    const SizedBox(height: 16),

                    // Streak
                    streakAsync.when(
                      data: (s) => StreakFireWidget(streak: s),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 16),

                    // Today's Quests
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ภารกิจวันนี้',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/quests'),
                          child: const Text('ดูทั้งหมด'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    questsAsync.when(
                      data: (quests) => Column(
                        children: quests
                            .take(3)
                            .map((q) => QuestCard(quest: q))
                            .toList(),
                      ),
                      loading: () => const LoadingView(),
                      error: (e, _) => Text('$e'),
                    ),

                    const SizedBox(height: 16),

                    // Recent Food Logs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'รายการอาหารวันนี้',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/food-log'),
                          child: const Text('ดูทั้งหมด'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    logsAsync.when(
                      data: (logs) => logs.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'ยังไม่มีรายการอาหาร\nกดปุ่ม "บันทึกอาหาร" เพื่อเริ่มต้น',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: logs
                                  .take(5)
                                  .map((l) => FoodLogCard(log: l))
                                  .toList(),
                            ),
                      loading: () => const LoadingView(),
                      error: (e, _) => Text('$e'),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MealCompletionBanner extends StatelessWidget {
  final Set<MealType> loggedMeals;
  const _MealCompletionBanner({required this.loggedMeals});

  @override
  Widget build(BuildContext context) {
    final main3 = {MealType.breakfast, MealType.lunch, MealType.dinner};
    final missing = main3.difference(loggedMeals);
    if (missing.isEmpty) return const SizedBox.shrink();

    final missingLabel = missing.map((m) => m.label).join(', ');

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.yellow.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.yellow.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'ยังไม่ได้บันทึก $missingLabel',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (icon: '📷', label: 'สแกนอาหาร', route: '/ai-scan'),
      (icon: '✏️', label: 'บันทึกด่วน', route: '/quick-log'),
      (icon: '🎲', label: 'สุ่มเมนู', route: '/random'),
      (icon: '💧', label: 'ดื่มน้ำ', route: '/water'),
    ];
    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () => context.go(a.route),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(a.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  Text(
                    a.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
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
