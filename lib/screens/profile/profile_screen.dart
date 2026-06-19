import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/macro_progress_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push('/profile-setup-edit'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text('$e')),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('กรุณาตั้งค่าโปรไฟล์'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/profile-setup'),
                    child: const Text('ตั้งค่าโปรไฟล์'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar + name
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            profile.displayName.isNotEmpty
                                ? profile.displayName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        profile.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Body info
                _InfoCard(
                  title: 'ข้อมูลร่างกาย',
                  children: [
                    _InfoRow(label: 'อายุ', value: '${profile.age} ปี'),
                    _InfoRow(
                        label: 'เพศ',
                        value: profile.gender.label),
                    _InfoRow(
                        label: 'ส่วนสูง',
                        value:
                            '${profile.heightCm.toStringAsFixed(1)} ซม.'),
                    _InfoRow(
                        label: 'น้ำหนัก',
                        value:
                            '${profile.weightKg.toStringAsFixed(1)} กก.'),
                    _InfoRow(
                        label: 'ระดับกิจกรรม',
                        value: profile.activityLevel.label),
                    _InfoRow(
                        label: 'เป้าหมาย',
                        value: profile.goal.label),
                  ],
                ),
                const SizedBox(height: 16),

                // Daily targets
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'เป้าหมายโภชนาการรายวัน',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'แคลอรี่ ${profile.dailyCalorieTarget.toStringAsFixed(0)} kcal / วัน',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.calorieColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      MacroProgressBar(
                        label: 'โปรตีน',
                        consumed: 0,
                        target: profile.dailyProteinTarget,
                        color: AppColors.proteinColor,
                      ),
                      const SizedBox(height: 12),
                      MacroProgressBar(
                        label: 'คาร์บ',
                        consumed: 0,
                        target: profile.dailyCarbTarget,
                        color: AppColors.carbColor,
                      ),
                      const SizedBox(height: 12),
                      MacroProgressBar(
                        label: 'ไขมัน',
                        consumed: 0,
                        target: profile.dailyFatTarget,
                        color: AppColors.fatColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Logout
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('ออกจากระบบ'),
                          content: const Text(
                              'คุณต้องการออกจากระบบหรือไม่?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('ยกเลิก'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error),
                              child: const Text('ออกจากระบบ'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await ref
                            .read(authNotifierProvider.notifier)
                            .logout();
                        if (context.mounted) context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout_rounded,
                        color: AppColors.error),
                    label: const Text(
                      'ออกจากระบบ',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppColors.shadowMedium, blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
