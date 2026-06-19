import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/water_provider.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/water_glass_grid.dart';

class WaterTrackerScreen extends ConsumerWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterAsync = ref.watch(todayWaterLogProvider);
    final waterAction = ref.watch(waterNotifierProvider);
    final isActionLoading = waterAction.isLoading;

    ref.listen<AsyncValue<void>>(waterNotifierProvider, (previous, next) {
      if (previous == null) return;

      final wasLoading = previous.isLoading;
      final isFinished = !next.isLoading && next.hasValue;

      if (wasLoading && isFinished) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('เพิ่มน้ำเรียบร้อยแล้ว'),
              duration: Duration(seconds: 2),
            ),
          );
      }

      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('ไม่สามารถเพิ่มน้ำได้ กรุณาลองใหม่อีกครั้ง'),
              duration: Duration(seconds: 3),
            ),
          );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('ติดตามการดื่มน้ำ')),
      body: waterAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text('$e')),
        data: (wl) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Hero progress ring
              Center(
                child: _WaterRing(percent: wl.progressPercent),
              ),
              const SizedBox(height: 24),
              Text(
                'ดื่มน้ำแล้ว ${wl.glassesDrunk} / 8 แก้ว',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${wl.totalMl.toStringAsFixed(0)} / 2,000 มล.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              WaterGlassGrid(
                waterLog: wl,
                onAddGlass: () =>
                    ref.read(waterNotifierProvider.notifier).addGlass(),
                onRemoveGlass: () =>
                    ref.read(waterNotifierProvider.notifier).removeGlass(),
              ),
              const SizedBox(height: 20),
              // Quick add button
              if (!wl.isCompleted)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isActionLoading
                        ? null
                        : () => ref.read(waterNotifierProvider.notifier).addGlass(),
                    icon: const Icon(Icons.water_drop_rounded),
                    label: isActionLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('เพิ่ม 1 แก้ว (250 มล.)'),
                  ),
                ),
              if (wl.glassesDrunk > 0) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: isActionLoading
                        ? null
                        : () => ref.read(waterNotifierProvider.notifier).removeGlass(),
                    icon: const Icon(Icons.remove_circle_outline),
                    label: isActionLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Text('ลบ 1 แก้ว'),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.waterColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.waterColor.withOpacity(0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 เคล็ดลับการดื่มน้ำ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.waterColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• ควรดื่มน้ำ 2,000 มล. (8 แก้ว) ต่อวัน\n'
                      '• ดื่มน้ำก่อนอาหาร 30 นาทีช่วยลดความอยากอาหาร\n'
                      '• หากออกกำลังกายควรเพิ่มน้ำอีก 500 มล.\n'
                      '• ดื่มน้ำอุ่นตอนเช้าช่วยกระตุ้นระบบเผาผลาญ',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterRing extends StatelessWidget {
  final double percent;
  const _WaterRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: percent,
              backgroundColor: AppColors.waterColor.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.waterColor),
              strokeWidth: 12,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💧', style: TextStyle(fontSize: 32)),
              Text(
                '${(percent * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.waterColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
