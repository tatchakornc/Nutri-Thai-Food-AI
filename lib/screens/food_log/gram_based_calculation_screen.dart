import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../constants/app_colors.dart';
import '../../models/food_log_model.dart';
import '../../providers/food_database_provider.dart';
import '../../providers/food_log_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/nutrition_calculator_service.dart';
import '../../utils/date_utils.dart' as appDate;
import '../../widgets/meal_type_selector.dart';
import '../../widgets/primary_button.dart';

class GramBasedCalculationScreen extends ConsumerStatefulWidget {
  const GramBasedCalculationScreen({super.key});

  @override
  ConsumerState<GramBasedCalculationScreen> createState() =>
      _GramBasedCalculationScreenState();
}

class _GramBasedCalculationScreenState
    extends ConsumerState<GramBasedCalculationScreen> {
  final _picker = ImagePicker();
  final _foodNameController = TextEditingController();
  File? _imageFile;
  MealType _mealType = MealType.lunch;
  final _uuid = const Uuid();
  List<_ComponentEntry> _components = [];

  // Search
  String _searchQuery = '';
  List _searchResults = [];
  bool _isSearching = false;

  double get _totalCalories =>
      _components.fold(0, (s, c) => s + c.component.calculatedCalories);
  double get _totalProtein =>
      _components.fold(0, (s, c) => s + c.component.calculatedProtein);
  double get _totalCarbs =>
      _components.fold(0, (s, c) => s + c.component.calculatedCarbs);
  double get _totalFat =>
      _components.fold(0, (s, c) => s + c.component.calculatedFat);

  Future<void> _pickImage(ImageSource source) async {
    final xfile = await _picker.pickImage(source: source, maxWidth: 1024);
    if (xfile == null) return;
    setState(() => _imageFile = File(xfile.path));
  }

  Future<void> _searchIngredients(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results =
        await ref.read(foodDatabaseServiceProvider).searchIngredients(q);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _addComponent({
    required String name,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
  }) {
    setState(() {
      _components.add(_ComponentEntry(
        nameController: TextEditingController(text: name),
        gramsController: TextEditingController(text: '100'),
        caloriesPer100g: caloriesPer100g,
        proteinPer100g: proteinPer100g,
        carbsPer100g: carbsPer100g,
        fatPer100g: fatPer100g,
        component: FoodComponent.calculate(
          componentName: name,
          grams: 100,
          caloriesPer100g: caloriesPer100g,
          proteinPer100g: proteinPer100g,
          carbsPer100g: carbsPer100g,
          fatPer100g: fatPer100g,
        ),
      ));
      _searchQuery = '';
      _searchResults = [];
    });
  }

  void _updateGrams(_ComponentEntry entry, String gramsStr) {
    final grams = double.tryParse(gramsStr) ?? 0;
    setState(() {
      entry.component = FoodComponent.calculate(
        componentName: entry.nameController.text,
        grams: grams,
        caloriesPer100g: entry.caloriesPer100g,
        proteinPer100g: entry.proteinPer100g,
        carbsPer100g: entry.carbsPer100g,
        fatPer100g: entry.fatPer100g,
      );
    });
  }

  Future<void> _save() async {
    if (_components.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเพิ่มส่วนประกอบอย่างน้อย 1 รายการ')),
      );
      return;
    }
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile == null) return;

    final log = FoodLogModel.fromComponents(
      logId: _uuid.v4(),
      userId: profile.uid,
      date: DateTime.parse(appDate.DateUtils.todayString()),
      mealType: _mealType,
      foodName: _foodNameController.text.trim().isEmpty
          ? 'อาหารคำนวณตามกรัม'
          : _foodNameController.text.trim(),
      components: _components.map((c) => c.component).toList(),
      imageUrl: '',
      notes: '',
    );

    await ref.read(foodLogNotifierProvider.notifier).addLog(log);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกอาหารสำเร็จ!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('คำนวณตามกรัม')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food name
            TextFormField(
              controller: _foodNameController,
              decoration: const InputDecoration(
                labelText: 'ชื่ออาหาร (ไม่บังคับ)',
                hintText: 'เช่น ข้าวไก่กระเทียมไข่ดาว',
                prefixIcon: Icon(Icons.restaurant_rounded,
                    color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),

            // Meal selector
            const Text(
              'มื้ออาหาร',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            MealTypeSelector(
              selected: _mealType,
              onChanged: (m) => setState(() => _mealType = m),
            ),

            const SizedBox(height: 20),

            // Search ingredients
            const Text(
              'ค้นหาส่วนประกอบ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _searchQuery,
              onChanged: (v) {
                _searchQuery = v;
                _searchIngredients(v);
              },
              decoration: const InputDecoration(
                hintText: 'พิมพ์ชื่อวัตถุดิบ เช่น ข้าวสวย ไก่ ไข่...',
                prefixIcon:
                    Icon(Icons.search_rounded, color: AppColors.primary),
              ),
            ),
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.all(8),
                child: LinearProgressIndicator(),
              ),
            if (_searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: _searchResults
                      .take(5)
                      .map((ing) => ListTile(
                            dense: true,
                            title: Text(ing.nameTh),
                            subtitle: Text(
                                '${ing.caloriesPer100g.toStringAsFixed(0)} kcal / 100g'),
                            trailing: const Icon(Icons.add_circle_rounded,
                                color: AppColors.primary),
                            onTap: () => _addComponent(
                              name: ing.nameTh,
                              caloriesPer100g: ing.caloriesPer100g,
                              proteinPer100g: ing.proteinPer100g,
                              carbsPer100g: ing.carbsPer100g,
                              fatPer100g: ing.fatPer100g,
                            ),
                          ))
                      .toList(),
                ),
              ),

            const SizedBox(height: 20),

            // Component list
            if (_components.isNotEmpty) ...[
              const Text(
                'ส่วนประกอบ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ..._components.asMap().entries.map((entry) {
                final idx = entry.key;
                final comp = entry.value;
                return _ComponentRow(
                  entry: comp,
                  onGramsChanged: (v) => _updateGrams(comp, v),
                  onRemove: () =>
                      setState(() => _components.removeAt(idx)),
                );
              }),

              // Totals
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'โภชนาการรวม',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _TotalChip(
                            label: 'แคลอรี่',
                            value: '${_totalCalories.toStringAsFixed(0)} kcal',
                            color: AppColors.calorieColor),
                        _TotalChip(
                            label: 'โปรตีน',
                            value: '${_totalProtein.toStringAsFixed(1)} g',
                            color: AppColors.proteinColor),
                        _TotalChip(
                            label: 'คาร์บ',
                            value: '${_totalCarbs.toStringAsFixed(1)} g',
                            color: AppColors.carbColor),
                        _TotalChip(
                            label: 'ไขมัน',
                            value: '${_totalFat.toStringAsFixed(1)} g',
                            color: AppColors.fatColor),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              PrimaryButton(
                label: 'บันทึก',
                onPressed: _save,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComponentEntry {
  final TextEditingController nameController;
  final TextEditingController gramsController;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  FoodComponent component;

  _ComponentEntry({
    required this.nameController,
    required this.gramsController,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.component,
  });
}

class _ComponentRow extends StatelessWidget {
  final _ComponentEntry entry;
  final ValueChanged<String> onGramsChanged;
  final VoidCallback onRemove;

  const _ComponentRow({
    required this.entry,
    required this.onGramsChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              entry.nameController.text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: entry.gramsController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: onGramsChanged,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                suffixText: 'g',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${entry.component.calculatedCalories.toStringAsFixed(0)} kcal',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.calorieColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: AppColors.error, size: 18),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _TotalChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ),
        Text(
          label,
          style:
              const TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}
