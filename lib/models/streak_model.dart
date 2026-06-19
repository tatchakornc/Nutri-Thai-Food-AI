import 'package:cloud_firestore/cloud_firestore.dart';

class StreakModel {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final String? lastLoggedDate; // yyyy-MM-dd
  final DateTime updatedAt;

  const StreakModel({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastLoggedDate,
    required this.updatedAt,
  });

  factory StreakModel.initial(String userId) {
    return StreakModel(
      userId: userId,
      currentStreak: 0,
      longestStreak: 0,
      lastLoggedDate: null,
      updatedAt: DateTime.now(),
    );
  }

  factory StreakModel.fromMap(Map<String, dynamic> map) {
    return StreakModel(
      userId: map['userId'] as String? ?? '',
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (map['longestStreak'] as num?)?.toInt() ?? 0,
      lastLoggedDate: map['lastLoggedDate'] as String?,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastLoggedDate': lastLoggedDate,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastLoggedDate,
    DateTime? updatedAt,
  }) {
    return StreakModel(
      userId: userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastLoggedDate: lastLoggedDate ?? this.lastLoggedDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
