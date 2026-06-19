import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app_colors.dart';
import '../../models/food_log_model.dart';
import '../../providers/food_log_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/date_utils.dart' as appDate;
import '../../utils/validators.dart';
import '../../widgets/meal_type_selector.dart';
import '../../widgets/primary_button.dart';

class QuickManualLogScreen extends ConsumerStatefulWidget {
  const QuickManualLogScreen({super.key});

  @override
  ConsumerState<QuickManualLogScreen> createState() =>
      _QuickManualLogScreenState();
}

class _QuickManualLogScreenState extends ConsumerState<QuickManualLogScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _notesController = TextEditingController();

  final _uuid = const Uuid();

  MealType _mealType = MealType.lunch;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _toDouble(String value) {
    return double.tryParse(value.trim()) ?? 0;
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final profile = ref.read(userProfileProvider).valueOrNull;

    if (profile == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('ไม่พบข้อมูลโปรไฟล์ผู้ใช้ กรุณาลองเข้าสู่ระบบใหม่'),
          ),
        );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final log = FoodLogModel(
      logId: _uuid.v4(),
      userId: profile.uid,
      date: DateTime.parse(appDate.DateUtils.todayString()),
      mealType: _mealType,
      foodName: _nameController.text.trim(),
      sourceType: FoodLogSourceType.quickManual,
      calories: _toDouble(_caloriesController.text),
      protein: _toDouble(_proteinController.text),
      carbs: _toDouble(_carbsController.text),
      fat: _toDouble(_fatController.text),
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(foodLogNotifierProvider.notifier).addLog(log);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('บันทึกอาหารสำเร็จ'),
            duration: Duration(seconds: 2),
          ),
        );

      ref.invalidate(todayFoodLogsProvider);
      ref.invalidate(todayNutritionProvider);
      ref.invalidate(loggedMealTypesProvider);
      ref.invalidate(recentFoodLogsProvider);

      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('บันทึกไม่สำเร็จ: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerSaving = ref.watch(foodLogNotifierProvider).isLoading;
    final isSaving = _isSaving || providerSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกด่วน'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: isSaving ? null : () => context.go('/food-log'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'มื้ออาหาร',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              MealTypeSelector(
                selected: _mealType,
                onChanged: isSaving
                    ? (_) {}
                    : (mealType) {
                        setState(() {
                          _mealType = mealType;
                        });
                      },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                enabled: !isSaving,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.required(value, 'ชื่ออาหาร'),
                decoration: const InputDecoration(
                  labelText: 'ชื่ออาหาร',
                  prefixIcon: Icon(
                    Icons.restaurant_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _caloriesController,
                enabled: !isSaving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    Validators.nonNegativeDouble(value, 'แคลอรี่'),
                decoration: InputDecoration(
                  labelText: 'แคลอรี่',
                  suffixText: 'kcal',
                  prefixIcon: Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.calorieColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      enabled: !isSaving,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          Validators.nonNegativeDouble(value, 'โปรตีน'),
                      decoration: const InputDecoration(
                        labelText: 'โปรตีน',
                        suffixText: 'g',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      enabled: !isSaving,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          Validators.nonNegativeDouble(value, 'คาร์บ'),
                      decoration: const InputDecoration(
                        labelText: 'คาร์บ',
                        suffixText: 'g',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      enabled: !isSaving,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          Validators.nonNegativeDouble(value, 'ไขมัน'),
                      decoration: const InputDecoration(
                        labelText: 'ไขมัน',
                        suffixText: 'g',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                enabled: !isSaving,
                maxLines: 2,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'หมายเหตุ (ไม่บังคับ)',
                  prefixIcon: Icon(
                    Icons.notes_rounded,
                    color: AppColors.textHint,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              PrimaryButton(
                label: 'บันทึก',
                onPressed: isSaving ? null : _save,
                isLoading: isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}