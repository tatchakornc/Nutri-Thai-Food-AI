import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/streak_model.dart';

class StreakFireWidget extends StatelessWidget {
  final StreakModel streak;
  final bool compact;

  const StreakFireWidget({
    super.key,
    required this.streak,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact();
    return _buildFull();
  }

  Widget _buildCompact() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.streakFire.withOpacity(0.15),
            AppColors.yellow.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.streakFire.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            '${streak.currentStreak}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.streakFire,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFull() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.streakFire.withOpacity(0.1),
            AppColors.yellow.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.streakFire.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          Text(
            '${streak.currentStreak}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.streakFire,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'วันติดต่อกัน',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'สูงสุด ${streak.longestStreak} วัน',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
