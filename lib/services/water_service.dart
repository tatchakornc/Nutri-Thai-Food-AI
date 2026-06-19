import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/water_log_model.dart';

class WaterService {
  final FirebaseFirestore _db;

  WaterService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _waterDoc(
    String userId,
    String date,
  ) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('waterLogs')
        .doc(date);
  }

  Stream<WaterLogModel> streamWaterLog(String userId, String date) {
    return _waterDoc(userId, date).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return WaterLogModel.empty(
          userId: userId,
          date: date,
        );
      }

      return WaterLogModel.fromMap(snap.data()!);
    });
  }

  Future<void> setWaterLog(WaterLogModel waterLog) async {
    await _waterDoc(waterLog.userId, waterLog.date).set(
      waterLog.toMap(),
      SetOptions(merge: true),
    );
  }

  Future<void> addGlass(String userId, String date) async {
    final snap = await _waterDoc(userId, date).get();

    final current = !snap.exists || snap.data() == null
        ? WaterLogModel.empty(userId: userId, date: date)
        : WaterLogModel.fromMap(snap.data()!);

    final updated = current.addGlass();

    await setWaterLog(updated);
  }

  Future<void> removeGlass(String userId, String date) async {
    final snap = await _waterDoc(userId, date).get();

    if (!snap.exists || snap.data() == null) return;

    final current = WaterLogModel.fromMap(snap.data()!);
    final updated = current.removeGlass();

    await setWaterLog(updated);
  }

  Future<WaterLogModel?> getWaterLog(String userId, String date) async {
    final snap = await _waterDoc(userId, date).get();

    if (!snap.exists || snap.data() == null) {
      return null;
    }

    return WaterLogModel.fromMap(snap.data()!);
  }
}