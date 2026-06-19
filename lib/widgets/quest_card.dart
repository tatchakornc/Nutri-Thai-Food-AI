import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/quest_model.dart';

class QuestCard extends StatelessWidget {
  final QuestModel quest;
  const QuestCard({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    final color = quest.isCompleted ? AppColors.primary : AppColors.accent;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: quest.isCompleted
              ? AppColors.primaryLight
              : AppColors.divider,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              quest.isCompleted
                  ? Icons.check_circle_rounded
                  : _questIcon(quest.type),
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: quest.isCompleted
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration: quest.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: quest.progressPercent,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quest.isCompleted
                      ? 'เสร็จแล้ว! 🎉'
                      : '${quest.progress.toStringAsFixed(quest.type == QuestType.hitProtein ? 1 : 0)} / ${quest.target.toStringAsFixed(quest.type == QuestType.hitProtein ? 0 : 0)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: quest.isCompleted
                        ? AppColors.primary
                        : AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _questIcon(QuestType type) {
    switch (type) {
      case QuestType.drinkWater: return Icons.water_drop_rounded;
      case QuestType.logMeals: return Icons.restaurant_rounded;
      case QuestType.hitProtein: return Icons.fitness_center_rounded;
      case QuestType.stayInCalories: return Icons.monitor_weight_rounded;
      case QuestType.logOneFood: return Icons.add_circle_outline_rounded;
    }
  }
}
