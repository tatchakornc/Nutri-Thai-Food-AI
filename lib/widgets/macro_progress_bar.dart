import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class MacroProgressBar extends StatelessWidget {
  final String label;
  final double consumed;
  final double target;
  final Color color;
  final String unit;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
    this.unit = 'g',
  });

  double get _percent => target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${consumed.toStringAsFixed(1)} / ${target.toStringAsFixed(0)} $unit',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: _percent,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
