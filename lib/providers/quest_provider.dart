import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quest_model.dart';
import 'auth_provider.dart';
import 'food_log_provider.dart';

/// Today's quests (live stream)
final todayQuestsProvider = StreamProvider<List<QuestModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(questServiceProvider).streamTodayQuests(user.uid);
});

/// Completed quests count
final completedQuestsCountProvider = Provider<int>((ref) {
  final quests = ref.watch(todayQuestsProvider).valueOrNull ?? [];
  return quests.where((q) => q.isCompleted).length;
});
