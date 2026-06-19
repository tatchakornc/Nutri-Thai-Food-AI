import 'package:cloud_firestore/cloud_firestore.dart';

enum QuestType {
  drinkWater('drink_water'),
  logMeals('log_meals'),
  hitProtein('hit_protein'),
  stayInCalories('stay_in_calories'),
  logOneFood('log_one_food');

  const QuestType(this.value);
  final String value;
}

class QuestModel {
  final String questId;
  final String userId;
  final String date; // yyyy-MM-dd
  final QuestType type;
  final String title;
  final String description;
  final double progress;
  final double target;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuestModel({
    required this.questId,
    required this.userId,
    required this.date,
    required this.type,
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercent => (progress / target).clamp(0.0, 1.0);

  factory QuestModel.fromMap(Map<String, dynamic> map, String docId) {
    return QuestModel(
      questId: docId,
      userId: map['userId'] as String? ?? '',
      date: map['date'] as String? ?? '',
      type: QuestType.values.firstWhere(
        (t) => t.value == map['type'],
        orElse: () => QuestType.logOneFood,
      ),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      progress: (map['progress'] as num?)?.toDouble() ?? 0,
      target: (map['target'] as num?)?.toDouble() ?? 1,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'questId': questId,
        'userId': userId,
        'date': date,
        'type': type.value,
        'title': title,
        'description': description,
        'progress': progress,
        'target': target,
        'isCompleted': isCompleted,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  QuestModel copyWith({
    double? progress,
    bool? isCompleted,
    DateTime? updatedAt,
  }) {
    return QuestModel(
      questId: questId,
      userId: userId,
      date: date,
      type: type,
      title: title,
      description: description,
      progress: progress ?? this.progress,
      target: target,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
