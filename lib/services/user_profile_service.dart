import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import 'nutrition_calculator_service.dart';

class UserProfileService {
  final FirebaseFirestore _db;

  UserProfileService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _db.collection('users').doc(uid);
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _userDoc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap(doc.data()!);
  }

  Stream<UserModel?> streamUserProfile(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return null;
      }

      return UserModel.fromMap(snap.data()!);
    });
  }

  Future<void> saveUserProfile(UserModel profile) async {
    final targets = NutritionCalculatorService.computeTargets(
      weightKg: profile.weightKg,
      heightCm: profile.heightCm,
      age: profile.age,
      gender: profile.gender,
      activityLevel: profile.activityLevel,
      goal: profile.goal,
    );

    final updated = profile.copyWith(
      dailyCalorieTarget: targets.calories,
      dailyProteinTarget: targets.protein,
      dailyCarbTarget: targets.carbs,
      dailyFatTarget: targets.fat,
      updatedAt: DateTime.now(),
    );

    await _userDoc(profile.uid).set(
      updated.toMap(),
      SetOptions(merge: true),
    );
  }

  Future<void> createInitialProfile(UserModel profile) async {
    await _userDoc(profile.uid).set(
      profile.toMap(),
      SetOptions(merge: true),
    );
  }

  Future<void> updateField(String uid, Map<String, dynamic> fields) async {
    await _userDoc(uid).update({
      ...fields,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}