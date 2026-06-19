import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/quest_model.dart';
import '../models/food_log_model.dart';
import '../models/water_log_model.dart';
import '../utils/date_utils.dart' as appDate;

class QuestService {
  final FirebaseFirestore _db;
  final _uuid = const Uuid();

  QuestService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _questsRef(String userId) =>
      _db.collection('users').doc(userId).collection('quests');

  Stream<List<QuestModel>> streamTodayQuests(String userId) {
    final today = appDate.DateUtils.todayString();
    return _questsRef(userId)
        .where('date', isEqualTo: today)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => QuestModel.fromMap(d.data(), d.id)).toList());
  }

  /// Initialize daily quests for today (call once per day)
  Future<void> initializeDailyQuests(
      String userId, double proteinTarget) async {
    final today = appDate.DateUtils.todayString();
    // Check if quests exist already
    final existing = await _questsRef(userId)
        .where('date', isEqualTo: today)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    final quests = _buildDailyQuests(userId, today, proteinTarget);
    final batch = _db.batch();
    for (final q in quests) {
      final ref = _questsRef(userId).doc(q.questId);
      batch.set(ref, q.toMap());
    }
    await batch.commit();
  }

  List<QuestModel> _buildDailyQuests(
      String userId, String date, double proteinTarget) {
    final now = DateTime.now();
    return [
      QuestModel(
        questId: _uuid.v4(),
        userId: userId,
        date: date,
        type: QuestType.drinkWater,
        title: 'ดื่มน้ำให้ครบ 8 แก้ว',
        description: 'ดื่มน้ำให้ได้ 8 แก้วต่อวัน (2,000 มล.)',
        progress: 0,
        target: 8,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      ),
      QuestModel(
        questId: _uuid.v4(),
        userId: userId,
        date: date,
        type: QuestType.logMeals,
        title: 'บันทึกอาหารให้ครบ 3 มื้อ',
        description: 'บันทึกทั้งมื้อเช้า กลางวัน และเย็น',
        progress: 0,
        target: 3,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      ),
      QuestModel(
        questId: _uuid.v4(),
        userId: userId,
        date: date,
        type: QuestType.hitProtein,
        title: 'กินโปรตีนให้ถึงเป้าหมาย',
        description: 'กินโปรตีนให้ได้ ${proteinTarget.toStringAsFixed(0)} กรัม',
        progress: 0,
        target: proteinTarget,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      ),
      QuestModel(
        questId: _uuid.v4(),
        userId: userId,
        date: date,
        type: QuestType.stayInCalories,
        title: 'อย่าให้แคลอรี่เกินเป้าหมาย',
        description: 'รักษาแคลอรี่ให้ไม่เกิน target',
        progress: 0,
        target: 1,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      ),
      QuestModel(
        questId: _uuid.v4(),
        userId: userId,
        date: date,
        type: QuestType.logOneFood,
        title: 'บันทึกอาหารอย่างน้อย 1 รายการวันนี้',
        description: 'บันทึกอาหารอย่างน้อย 1 มื้อ',
        progress: 0,
        target: 1,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Update quest progress based on current food logs and water
  Future<void> updateQuestProgress({
    required String userId,
    required List<FoodLogModel> todayLogs,
    required WaterLogModel waterLog,
    required double calorieTarget,
    required double proteinTarget,
  }) async {
    final today = appDate.DateUtils.todayString();
    final snap = await _questsRef(userId)
        .where('date', isEqualTo: today)
        .get();

    if (snap.docs.isEmpty) return;

    final totalProtein =
        todayLogs.fold(0.0, (s, l) => s + l.protein);
    final totalCalories =
        todayLogs.fold(0.0, (s, l) => s + l.calories);
    final mealTypes = todayLogs.map((l) => l.mealType).toSet();
    final uniqueMeals = {
      MealType.breakfast,
      MealType.lunch,
      MealType.dinner
    }.intersection(mealTypes).length;

    final batch = _db.batch();
    for (final doc in snap.docs) {
      final quest = QuestModel.fromMap(doc.data(), doc.id);
      double progress = quest.progress;
      bool completed = quest.isCompleted;

      switch (quest.type) {
        case QuestType.drinkWater:
          progress = waterLog.glassesDrunk.toDouble();
          completed = waterLog.isCompleted;
        case QuestType.logMeals:
          progress = uniqueMeals.toDouble();
          completed = uniqueMeals >= 3;
        case QuestType.hitProtein:
          progress = totalProtein;
          completed = totalProtein >= proteinTarget;
        case QuestType.stayInCalories:
          progress = totalCalories <= calorieTarget ? 1 : 0;
          completed = totalCalories <= calorieTarget && totalLogs > 0;
        case QuestType.logOneFood:
          progress = todayLogs.isNotEmpty ? 1 : 0;
          completed = todayLogs.isNotEmpty;
      }

      final updated = quest.copyWith(
        progress: progress,
        isCompleted: completed,
        updatedAt: DateTime.now(),
      );
      batch.update(doc.reference, updated.toMap());
    }
    await batch.commit();
  }

  int get totalLogs => 0; // placeholder — passed in context above
}
