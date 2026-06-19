import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/nutrition_calculator_service.dart';
import '../../utils/validators.dart';
import '../../widgets/primary_button.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final bool isEditing;
  const ProfileSetupScreen({super.key, this.isEditing = false});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  Gender _gender = Gender.male;
  ActivityLevel _activity = ActivityLevel.moderatelyActive;
  Goal _goal = Goal.maintain;
  NutritionTargets? _targets;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final profile = ref.read(userProfileProvider).valueOrNull;
        if (profile != null) _populateFields(profile);
      });
    }
  }

  void _populateFields(UserModel p) {
    _ageController.text = p.age.toString();
    _heightController.text = p.heightCm.toString();
    _weightController.text = p.weightKg.toString();
    setState(() {
      _gender = p.gender;
      _activity = p.activityLevel;
      _goal = p.goal;
    });
    _calculate();
  }

  void _calculate() {
    final age = int.tryParse(_ageController.text);
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    if (age == null || height == null || weight == null) return;
    setState(() {
      _targets = NutritionCalculatorService.computeTargets(
        weightKg: weight,
        heightCm: height,
        age: age,
        gender: _gender,
        activityLevel: _activity,
        goal: _goal,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _calculate();
    final targets = _targets;
    if (targets == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('ไม่พบผู้ใช้ กรุณาเข้าสู่ระบบใหม่'),
              duration: Duration(seconds: 3),
            ),
          );
      }
      return;
    }

    final profile = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      age: int.parse(_ageController.text),
      gender: _gender,
      heightCm: double.parse(_heightController.text),
      weightKg: double.parse(_weightController.text),
      activityLevel: _activity,
      goal: _goal,
      dailyCalorieTarget: targets.calories,
      dailyProteinTarget: targets.protein,
      dailyCarbTarget: targets.carbs,
      dailyFatTarget: targets.fat,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final notifier = ref.read(profileNotifierProvider.notifier);
    await notifier.saveProfile(profile);

    final state = ref.read(profileNotifierProvider);
    state.when(
      data: (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('บันทึกโปรไฟล์สำเร็จ!'),
              duration: Duration(seconds: 2),
            ),
          );
        if (widget.isEditing) {
          Navigator.of(context).pop();
        } else {
          context.go('/home');
        }
      },
      error: (error, _) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text('บันทึกล้มเหลว: $error'),
              duration: const Duration(seconds: 3),
            ),
          );
      },
      loading: () {},
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(profileNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'แก้ไขโปรไฟล์' : 'ตั้งค่าโปรไฟล์'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isEditing) ...[
                  const Text(
                    'บอกเราเกี่ยวกับตัวคุณ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'ข้อมูลนี้จะใช้คำนวณเป้าหมายโภชนาการของคุณ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                ],

                // Age
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.positiveInt(v, 'อายุ'),
                  onChanged: (_) => _calculate(),
                  decoration: const InputDecoration(
                    labelText: 'อายุ (ปี)',
                    prefixIcon: Icon(Icons.cake_outlined, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),

                // Height
                TextFormField(
                  controller: _heightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.positiveDouble(v, 'ส่วนสูง'),
                  onChanged: (_) => _calculate(),
                  decoration: const InputDecoration(
                    labelText: 'ส่วนสูง (ซม.)',
                    prefixIcon:
                        Icon(Icons.height_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),

                // Weight
                TextFormField(
                  controller: _weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.positiveDouble(v, 'น้ำหนัก'),
                  onChanged: (_) => _calculate(),
                  decoration: const InputDecoration(
                    labelText: 'น้ำหนัก (กก.)',
                    prefixIcon: Icon(Icons.monitor_weight_outlined,
                        color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 20),

                // Gender
                _SectionLabel(label: 'เพศ'),
                const SizedBox(height: 8),
                Row(
                  children: Gender.values.map((g) {
                    final selected = _gender == g;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _gender = g;
                          _calculate();
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              g.value == 'male' ? '👨 ${g.label}' : '👩 ${g.label}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Activity Level
                _SectionLabel(label: 'ระดับกิจกรรม'),
                const SizedBox(height: 8),
                ...ActivityLevel.values.map((a) => _RadioTile<ActivityLevel>(
                      value: a,
                      groupValue: _activity,
                      label: a.label,
                      subtitle: 'x${a.multiplier.toStringAsFixed(3)}',
                      onChanged: (v) => setState(() {
                        _activity = v!;
                        _calculate();
                      }),
                    )),

                const SizedBox(height: 20),

                // Goal
                _SectionLabel(label: 'เป้าหมาย'),
                const SizedBox(height: 8),
                ...Goal.values.map((g) => _RadioTile<Goal>(
                      value: g,
                      groupValue: _goal,
                      label: g.label,
                      subtitle: g == Goal.lose
                          ? 'TDEE - 500 kcal'
                          : g == Goal.gain
                              ? 'TDEE + 300 kcal'
                              : 'TDEE',
                      onChanged: (v) => setState(() {
                        _goal = v!;
                        _calculate();
                      }),
                    )),

                // Targets preview
                if (_targets != null) ...[
                  const SizedBox(height: 24),
                  _TargetsPreview(targets: _targets!),
                ],

                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'บันทึกโปรไฟล์',
                  onPressed: isSaving ? null : _save,
                  isLoading: isSaving,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _RadioTile<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String label;
  final String subtitle;
  final ValueChanged<T?> onChanged;

  const _RadioTile({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.subtitle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySurface : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.primary : AppColors.textHint,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetsPreview extends StatelessWidget {
  final NutritionTargets targets;
  const _TargetsPreview({required this.targets});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primarySurface, Color(0xFFF0FBF4)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 6),
              Text(
                'เป้าหมายโภชนาการรายวัน',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _TargetChip(
                label: 'BMR',
                value: '${targets.bmr.toStringAsFixed(0)} kcal',
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              _TargetChip(
                label: 'TDEE',
                value: '${targets.tdee.toStringAsFixed(0)} kcal',
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _TargetChip(
                label: 'แคลอรี่',
                value: '${targets.calories.toStringAsFixed(0)} kcal',
                color: AppColors.calorieColor,
              ),
              const SizedBox(width: 8),
              _TargetChip(
                label: 'โปรตีน',
                value: '${targets.protein.toStringAsFixed(1)} g',
                color: AppColors.proteinColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _TargetChip(
                label: 'คาร์บ',
                value: '${targets.carbs.toStringAsFixed(1)} g',
                color: AppColors.carbColor,
              ),
              const SizedBox(width: 8),
              _TargetChip(
                label: 'ไขมัน',
                value: '${targets.fat.toStringAsFixed(1)} g',
                color: AppColors.fatColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _TargetChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
