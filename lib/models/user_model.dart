import 'package:cloud_firestore/cloud_firestore.dart';

/// Activity level multiplier for TDEE calculation
enum ActivityLevel {
  sedentary(1.2, 'ไม่ค่อยเคลื่อนไหว'),
  lightlyActive(1.375, 'เคลื่อนไหวเล็กน้อย'),
  moderatelyActive(1.55, 'เคลื่อนไหวปานกลาง'),
  veryActive(1.725, 'เคลื่อนไหวมาก'),
  extraActive(1.9, 'เคลื่อนไหวมากพิเศษ');

  const ActivityLevel(this.multiplier, this.label);
  final double multiplier;
  final String label;
}

enum Goal {
  lose('lose', 'ลดน้ำหนัก'),
  maintain('maintain', 'คงน้ำหนัก'),
  gain('gain', 'เพิ่มน้ำหนัก');

  const Goal(this.value, this.label);
  final String value;
  final String label;
}

enum Gender {
  male('male', 'ชาย'),
  female('female', 'หญิง');

  const Gender(this.value, this.label);
  final String value;
  final String label;
}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int age;
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;
  final Goal goal;
  final double dailyCalorieTarget;
  final double dailyProteinTarget;
  final double dailyCarbTarget;
  final double dailyFatTarget;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.goal,
    required this.dailyCalorieTarget,
    required this.dailyProteinTarget,
    required this.dailyCarbTarget,
    required this.dailyFatTarget,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a minimal user model from Firebase Auth (before profile setup)
  factory UserModel.initial({
    required String uid,
    required String email,
    required String displayName,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      age: 25,
      gender: Gender.male,
      heightCm: 170,
      weightKg: 65,
      activityLevel: ActivityLevel.sedentary,
      goal: Goal.maintain,
      dailyCalorieTarget: 2000,
      dailyProteinTarget: 130,
      dailyCarbTarget: 250,
      dailyFatTarget: 65,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String? ?? '',
      age: (map['age'] as num?)?.toInt() ?? 25,
      gender: Gender.values.firstWhere(
        (g) => g.value == map['gender'],
        orElse: () => Gender.male,
      ),
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 170,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 65,
      activityLevel: ActivityLevel.values.firstWhere(
        (a) => a.name == map['activityLevel'],
        orElse: () => ActivityLevel.sedentary,
      ),
      goal: Goal.values.firstWhere(
        (g) => g.value == map['goal'],
        orElse: () => Goal.maintain,
      ),
      dailyCalorieTarget: (map['dailyCalorieTarget'] as num?)?.toDouble() ?? 2000,
      dailyProteinTarget: (map['dailyProteinTarget'] as num?)?.toDouble() ?? 130,
      dailyCarbTarget: (map['dailyCarbTarget'] as num?)?.toDouble() ?? 250,
      dailyFatTarget: (map['dailyFatTarget'] as num?)?.toDouble() ?? 65,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'age': age,
      'gender': gender.value,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel.name,
      'goal': goal.value,
      'dailyCalorieTarget': dailyCalorieTarget,
      'dailyProteinTarget': dailyProteinTarget,
      'dailyCarbTarget': dailyCarbTarget,
      'dailyFatTarget': dailyFatTarget,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    int? age,
    Gender? gender,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    Goal? goal,
    double? dailyCalorieTarget,
    double? dailyProteinTarget,
    double? dailyCarbTarget,
    double? dailyFatTarget,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      dailyProteinTarget: dailyProteinTarget ?? this.dailyProteinTarget,
      dailyCarbTarget: dailyCarbTarget ?? this.dailyCarbTarget,
      dailyFatTarget: dailyFatTarget ?? this.dailyFatTarget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
