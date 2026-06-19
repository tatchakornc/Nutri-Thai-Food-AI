import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/food_log_model.dart';

class FoodLogService {
  final FirebaseFirestore _db;
  final _uuid = const Uuid();

  FoodLogService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _logsRef(String userId) =>
      _db.collection('users').doc(userId).collection('foodLogs');

  /// Stream all logs for a specific date (yyyy-MM-dd)
  Stream<List<FoodLogModel>> streamLogsForDate(
      String userId, String date) {
    final start = _dateStart(date);
    final end = _dateEnd(date);
    return _logsRef(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FoodLogModel.fromMap(d.data(), d.id))
            .toList());
  }

  /// Get all food logs sorted by most recent (for history screen)
  Future<List<FoodLogModel>> getRecentLogs(String userId,
      {int limit = 30}) async {
    final snap = await _logsRef(userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => FoodLogModel.fromMap(d.data(), d.id))
        .toList();
  }

  /// Add a new food log
  Future<String> addFoodLog(String userId, FoodLogModel log) async {
    final id = _uuid.v4();
    await _logsRef(userId).doc(id).set(log.toMap());
    return id;
  }

  /// Delete a food log
  Future<void> deleteFoodLog(String userId, String logId) async {
    await _logsRef(userId).doc(logId).delete();
  }

  /// Update a food log
  Future<void> updateFoodLog(
      String userId, String logId, FoodLogModel log) async {
    await _logsRef(userId).doc(logId).update(log.toMap());
  }

  /// Sum today's nutrition from a list of logs
  static ({
    double calories,
    double protein,
    double carbs,
    double fat
  }) sumNutrition(List<FoodLogModel> logs) {
    return (
      calories: logs.fold(0.0, (s, l) => s + l.calories),
      protein: logs.fold(0.0, (s, l) => s + l.protein),
      carbs: logs.fold(0.0, (s, l) => s + l.carbs),
      fat: logs.fold(0.0, (s, l) => s + l.fat),
    );
  }

  /// Check which meal types have been logged today
  static Set<MealType> loggedMealTypes(List<FoodLogModel> logs) {
    return logs.map((l) => l.mealType).toSet();
  }

  DateTime _dateStart(String date) {
    final parts = date.split('-');
    return DateTime(
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  DateTime _dateEnd(String date) {
    final parts = date.split('-');
    return DateTime(
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]),
        23, 59, 59);
  }
}
