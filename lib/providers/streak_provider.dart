import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/streak_model.dart';
import '../services/streak_service.dart';
import 'auth_provider.dart';
import 'food_log_provider.dart';

/// Live streak stream
final streakProvider = StreamProvider<StreakModel>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(streakServiceProvider).streamStreak(user.uid);
});
