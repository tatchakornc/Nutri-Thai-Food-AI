import 'package:cloud_firestore/cloud_firestore.dart';

class WaterLogModel {
  final String userId;
  final String date; // yyyy-MM-dd
  final int glassesDrunk;
  final double totalMl;
  final DateTime updatedAt;

  static const int maxGlasses = 8;
  static const double mlPerGlass = 250;

  const WaterLogModel({
    required this.userId,
    required this.date,
    required this.glassesDrunk,
    required this.totalMl,
    required this.updatedAt,
  });

  factory WaterLogModel.empty({
    required String userId,
    required String date,
  }) {
    return WaterLogModel(
      userId: userId,
      date: date,
      glassesDrunk: 0,
      totalMl: 0,
      updatedAt: DateTime.now(),
    );
  }

  factory WaterLogModel.fromMap(Map<String, dynamic> map) {
    return WaterLogModel(
      userId: map['userId'] as String? ?? '',
      date: map['date'] as String? ?? '',
      glassesDrunk: (map['glassesDrunk'] as num?)?.toInt() ?? 0,
      totalMl: (map['totalMl'] as num?)?.toDouble() ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'date': date,
        'glassesDrunk': glassesDrunk,
        'totalMl': totalMl,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  WaterLogModel addGlass() {
    if (glassesDrunk >= maxGlasses) return this;
    return WaterLogModel(
      userId: userId,
      date: date,
      glassesDrunk: glassesDrunk + 1,
      totalMl: totalMl + mlPerGlass,
      updatedAt: DateTime.now(),
    );
  }

  WaterLogModel removeGlass() {
    if (glassesDrunk <= 0) return this;
    return WaterLogModel(
      userId: userId,
      date: date,
      glassesDrunk: glassesDrunk - 1,
      totalMl: totalMl - mlPerGlass,
      updatedAt: DateTime.now(),
    );
  }

  bool get isCompleted => glassesDrunk >= maxGlasses;

  double get progressPercent => glassesDrunk / maxGlasses;
}
