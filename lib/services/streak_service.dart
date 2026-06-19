import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/streak_model.dart';
import '../utils/date_utils.dart' as appDate;

class StreakService {
  final FirebaseFirestore _db;

  StreakService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _streakDoc(String userId) =>
      _db.collection('users').doc(userId).collection('streak').doc('data');

  Stream<StreakModel> streamStreak(String userId) {
    return _streakDoc(userId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return StreakModel.initial(userId);
      }
      return StreakModel.fromMap(snap.data()!);
    });
  }

  Future<StreakModel> getStreak(String userId) async {
    final snap = await _streakDoc(userId).get();
    if (!snap.exists || snap.data() == null) return StreakModel.initial(userId);
    return StreakModel.fromMap(snap.data()!);
  }

  /// Call this after any food log is saved today.
  /// Rules: streak increments once per day; missing a day resets to 0.
  Future<StreakModel> updateStreak(String userId) async {
    final today = appDate.DateUtils.todayString();
    final current = await getStreak(userId);

    // Already updated today — no-op
    if (current.lastLoggedDate == today) return current;

    int newStreak;
    if (current.lastLoggedDate == null) {
      // First ever log
      newStreak = 1;
    } else {
      final lastDate = DateTime.parse(current.lastLoggedDate!);
      final todayDate = DateTime.parse(today);
      final diff = todayDate.difference(lastDate).inDays;
      if (diff == 1) {
        // Consecutive day
        newStreak = current.currentStreak + 1;
      } else {
        // Missed day(s)
        newStreak = 1;
      }
    }

    final updated = current.copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > current.longestStreak
          ? newStreak
          : current.longestStreak,
      lastLoggedDate: today,
      updatedAt: DateTime.now(),
    );

    await _streakDoc(userId).set(updated.toMap(), SetOptions(merge: true));
    return updated;
  }
}
