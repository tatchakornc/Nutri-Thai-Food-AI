import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../models/food_log_model.dart';
import '../../providers/food_log_provider.dart';
import '../../utils/date_utils.dart' as appDate;
import '../../widgets/empty_state_widget.dart';
import '../../widgets/food_log_card.dart';
import '../../widgets/loading_view.dart';

class FoodLogScreen extends ConsumerWidget {
  const FoodLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(todayFoodLogsProvider);
    final nutrition = ref.watch(todayNutritionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('บันทึกอาหาร'),
            Text(
              appDate.DateUtils.displayDate(DateTime.now()),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Nutrition summary bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(
                    label: 'แคลอรี่',
                    value: '${nutrition.calories.toStringAsFixed(0)} kcal',
                    color: AppColors.calorieColor),
                _MiniStat(
                    label: 'โปรตีน',
                    value: '${nutrition.protein.toStringAsFixed(1)} g',
                    color: AppColors.proteinColor),
                _MiniStat(
                    label: 'คาร์บ',
                    value: '${nutrition.carbs.toStringAsFixed(1)} g',
                    color: AppColors.carbColor),
                _MiniStat(
                    label: 'ไขมัน',
                    value: '${nutrition.fat.toStringAsFixed(1)} g',
                    color: AppColors.fatColor),
              ],
            ),
          ),
          const Divider(height: 1),

          // Log methods
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _LogMethodButton(
                  icon: '📷',
                  label: 'สแกน AI',
                  onTap: () => context.push('/ai-scan'),
                ),
                const SizedBox(width: 8),
                _LogMethodButton(
                  icon: '🕐',
                  label: 'ประวัติ',
                  onTap: () => context.push('/food-history'),
                ),
                const SizedBox(width: 8),
                _LogMethodButton(
                  icon: '✏️',
                  label: 'บันทึกด่วน',
                  onTap: () => context.push('/quick-log'),
                ),
                const SizedBox(width: 8),
                _LogMethodButton(
                  icon: '⚖️',
                  label: 'คำนวณกรัม',
                  onTap: () => context.push('/gram-based'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: logsAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => Center(child: Text('$e')),
              data: (logs) {
                if (logs.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'ยังไม่มีรายการอาหาร',
                    subtitle: 'เลือกวิธีบันทึกอาหารด้านบน',
                  );
                }

                // Group by meal type
                final grouped = <MealType, List<FoodLogModel>>{};
                for (final log in logs) {
                  grouped.putIfAbsent(log.mealType, () => []).add(log);
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: MealType.values.where((m) => grouped.containsKey(m)).map((mealType) {
                    final items = grouped[mealType]!;
                    final total = items.fold(0.0, (s, l) => s + l.calories);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                mealType.emoji,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                mealType.label,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${total.toStringAsFixed(0)} kcal',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.calorieColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...items.map((log) => FoodLogCard(
                              log: log,
                              onDelete: () => _confirmDelete(
                                  context, ref, log.logId),
                            )),
                        const SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String logId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบรายการนี้?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(foodLogNotifierProvider.notifier).deleteLog(logId);
    }
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

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
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }
}

class _LogMethodButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _LogMethodButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryLight),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
