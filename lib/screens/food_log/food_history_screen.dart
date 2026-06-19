import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../constants/app_colors.dart';
import '../../models/food_log_model.dart';
import '../../providers/food_log_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/date_utils.dart' as appDate;
import '../../widgets/empty_state_widget.dart';
import '../../widgets/food_log_card.dart';
import '../../widgets/loading_view.dart';

class FoodHistoryScreen extends ConsumerStatefulWidget {
  const FoodHistoryScreen({super.key});

  @override
  ConsumerState<FoodHistoryScreen> createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends ConsumerState<FoodHistoryScreen> {
  String _searchQuery = '';
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final recentAsync = ref.watch(recentFoodLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ประวัติอาหาร')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'ค้นหาอาหาร...',
                prefixIcon:
                    Icon(Icons.search_rounded, color: AppColors.primary),
              ),
            ),
          ),
          Expanded(
            child: recentAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => Center(child: Text('$e')),
              data: (logs) {
                // Deduplicate by food name
                final seen = <String>{};
                final unique = logs.where((l) {
                  if (seen.contains(l.foodName)) return false;
                  seen.add(l.foodName);
                  return true;
                }).toList();

                final filtered = _searchQuery.isEmpty
                    ? unique
                    : unique
                        .where((l) => l.foodName
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.history_rounded,
                    title: 'ยังไม่มีประวัติอาหาร',
                    subtitle: 'อาหารที่เคยบันทึกจะปรากฏที่นี่',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final log = filtered[i];
                    return FoodLogCard(
                      log: log,
                      onTap: () => _addToToday(log),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToToday(FoodLogModel original) async {
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile == null) return;

    final newLog = FoodLogModel(
      logId: _uuid.v4(),
      userId: profile.uid,
      date: DateTime.parse(appDate.DateUtils.todayString()),
      mealType: original.mealType,
      foodName: original.foodName,
      sourceType: FoodLogSourceType.history,
      calories: original.calories,
      protein: original.protein,
      carbs: original.carbs,
      fat: original.fat,
      imageUrl: original.imageUrl,
      components: original.components,
      notes: '',
      createdAt: DateTime.now(),
    );

    await ref.read(foodLogNotifierProvider.notifier).addLog(newLog);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เพิ่ม "${original.foodName}" สำเร็จ!')),
      );
    }
  }
}
