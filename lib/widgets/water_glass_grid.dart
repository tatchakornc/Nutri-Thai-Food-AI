import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/water_log_model.dart';

/// 8-glass water tracker grid with fill animation
class WaterGlassGrid extends StatelessWidget {
  final WaterLogModel waterLog;
  final VoidCallback onAddGlass;
  final VoidCallback onRemoveGlass;

  const WaterGlassGrid({
    super.key,
    required this.waterLog,
    required this.onAddGlass,
    required this.onRemoveGlass,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_rounded,
                  color: AppColors.waterColor, size: 22),
              const SizedBox(width: 8),
              const Text(
                'การดื่มน้ำ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'ดื่มน้ำแล้ว ${waterLog.glassesDrunk}/${WaterLogModel.maxGlasses} แก้ว',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${waterLog.totalMl.toStringAsFixed(0)} / ${(WaterLogModel.maxGlasses * WaterLogModel.mlPerGlass).toStringAsFixed(0)} มล.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          // 8 glass icons in 2 rows of 4
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: WaterLogModel.maxGlasses,
            itemBuilder: (context, index) {
              final isFilled = index < waterLog.glassesDrunk;
              return GestureDetector(
                onTap: () {
                  if (!isFilled) {
                    onAddGlass();
                  } else if (index == waterLog.glassesDrunk - 1) {
                    // Allow un-tapping only the last glass
                    onRemoveGlass();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isFilled
                        ? AppColors.waterColor.withOpacity(0.15)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isFilled
                          ? AppColors.waterColor
                          : AppColors.divider,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFilled
                            ? Icons.water_drop_rounded
                            : Icons.water_drop_outlined,
                        color: isFilled
                            ? AppColors.waterColor
                            : AppColors.textHint,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isFilled
                              ? AppColors.waterColor
                              : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (waterLog.isCompleted) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'ดื่มน้ำครบแล้ว! 🎉',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
