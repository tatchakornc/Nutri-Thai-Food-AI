import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app_colors.dart';
import '../../models/food_log_model.dart';
import '../../providers/food_database_provider.dart';
import '../../providers/food_log_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/ai_food_recognition_service.dart';
import '../../utils/date_utils.dart' as appDate;
import '../../widgets/loading_view.dart';
import '../../widgets/meal_type_selector.dart';
import '../../widgets/primary_button.dart';

class AIFoodScanScreen extends ConsumerStatefulWidget {
  const AIFoodScanScreen({super.key});

  @override
  ConsumerState<AIFoodScanScreen> createState() => _AIFoodScanScreenState();
}

class _AIFoodScanScreenState extends ConsumerState<AIFoodScanScreen> {
  final _picker = ImagePicker();
  final _uuid = const Uuid();

  XFile? _pickedImage;
  Uint8List? _imageBytes;

  bool _isAnalyzing = false;
  bool _isSaving = false;

  AIRecognitionResult? _result;
  MealType _selectedMealType = MealType.lunch;
  List<_EditableItem> _editableItems = [];

  @override
  void dispose() {
    for (final item in _editableItems) {
      item.nameController.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xfile = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 85,
      );

      if (xfile == null) return;

      final bytes = await xfile.readAsBytes();

      for (final item in _editableItems) {
        item.nameController.dispose();
      }

      setState(() {
        _pickedImage = xfile;
        _imageBytes = bytes;
        _result = null;
        _editableItems = [];
      });

      await _analyze();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('เลือกรูปไม่สำเร็จ: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
    }
  }

  Future<void> _analyze() async {
    if (_pickedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final service = ref.read(aiRecognitionServiceProvider);

      final ext = _pickedImage!.name.split('.').last.toLowerCase();

      final mimeType = switch (ext) {
       'png' => 'image/png',
       'webp' => 'image/webp',
       _ => 'image/jpeg',
      };

      final result = await service.recognizeFood(
       imageFile: kIsWeb ? null : File(_pickedImage!.path),
       imageBytes: _imageBytes,
       mimeType: mimeType,
      );

      if (!result.success) {
        throw Exception(result.errorMessage ?? 'AI วิเคราะห์รูปไม่สำเร็จ');
      }

      for (final item in _editableItems) {
        item.nameController.dispose();
      }

      setState(() {
        _result = result;
        _editableItems = result.detectedItems.map((item) {
          return _EditableItem(
            detected: item,
            nameController: TextEditingController(
              text: item.matchedFoodNameTh ?? item.detectedName,
            ),
          );
        }).toList();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('วิเคราะห์อาหารไม่สำเร็จ: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _saveLogs() async {
    if (_isSaving) return;

    final profile = ref.read(userProfileProvider).valueOrNull;

    if (profile == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่'),
            duration: Duration(seconds: 3),
          ),
        );
      return;
    }

    final confirmedItems =
        _editableItems.where((item) => item.isConfirmed).toList();

    if (confirmedItems.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('กรุณาเลือกรายการอาหารอย่างน้อย 1 รายการ'),
            duration: Duration(seconds: 3),
          ),
        );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final today = appDate.DateUtils.todayString();
      final notifier = ref.read(foodLogNotifierProvider.notifier);
      final dbService = ref.read(foodDatabaseServiceProvider);

      var savedCount = 0;

      for (final item in confirmedItems) {
        final typedName = item.nameController.text.trim();

        if (typedName.isEmpty) continue;

        final matchedByName = await dbService.matchFoodByName(typedName);

        final food = matchedByName ??
            (item.detected.matchedFoodId != null
                ? await dbService.getFoodById(item.detected.matchedFoodId!)
                : null);

        final log = FoodLogModel(
          logId: _uuid.v4(),
          userId: profile.uid,
          date: DateTime.parse(today),
          mealType: _selectedMealType,
          foodName: food?.nameTh ?? typedName,
          sourceType: FoodLogSourceType.aiScan,
          calories: food?.calories ?? 0,
          protein: food?.protein ?? 0,
          carbs: food?.carbs ?? 0,
          fat: food?.fat ?? 0,
          imageUrl: '',
          notes: food == null
              ? 'AI ตรวจพบ: ${item.detected.detectedName}, แต่ยังไม่พบในฐานข้อมูลอาหาร'
              : 'AI ตรวจพบ: ${item.detected.detectedName}',
          createdAt: DateTime.now(),
        );

        await notifier.addLog(log);
        savedCount++;
      }

      if (!mounted) return;

      if (savedCount == 0) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('ยังไม่มีรายการที่สามารถบันทึกได้'),
              duration: Duration(seconds: 3),
            ),
          );
        return;
      }

      ref.invalidate(todayFoodLogsProvider);
      ref.invalidate(todayNutritionProvider);
      ref.invalidate(loggedMealTypesProvider);
      ref.invalidate(recentFoodLogsProvider);

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('บันทึกอาหารสำเร็จ'),
            duration: Duration(seconds: 2),
          ),
        );

      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('บันทึกอาหารไม่สำเร็จ: $e'),
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

  Widget _buildImagePreview() {
    if (_imageBytes == null) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_rounded,
            size: 48,
            color: AppColors.primary,
          ),
          SizedBox(height: 12),
          Text(
            'แตะเพื่อถ่ายหรืออัปโหลดภาพอาหาร',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    if (kIsWeb) {
      return Image.memory(
        _imageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_pickedImage != null) {
      return Image.file(
        File(_pickedImage!.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Image.memory(
      _imageBytes!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('ถ่ายภาพ'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('เลือกจากคลังภาพ'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasConfirmedItem = _editableItems.any((item) => item.isConfirmed);
    final isBusy = _isAnalyzing || _isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('สแกนอาหารด้วย AI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: isBusy ? null : () => context.go('/food-log'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: isBusy ? null : _showImageSourceSheet,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryLight,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _buildImagePreview(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        isBusy ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('ถ่ายภาพ'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        isBusy ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('อัปโหลด'),
                  ),
                ),
              ],
            ),

            if (_isAnalyzing) ...[
              const SizedBox(height: 24),
              const LoadingView(message: 'กำลังให้ AI วิเคราะห์อาหาร...'),
            ],

            if (_result != null && !_isAnalyzing) ...[
              const SizedBox(height: 24),
              const Text(
                'อาหารที่ AI ตรวจพบ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'ระบบจะนำชื่ออาหารไปเทียบกับฐานข้อมูลอาหารไทยเพื่อคำนวณสารอาหาร',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              ..._editableItems.map(
                (item) {
                  return _DetectedItemRow(
                    item: item,
                    onToggle: isBusy
                        ? null
                        : () {
                            setState(() {
                              item.isConfirmed = !item.isConfirmed;
                            });
                          },
                  );
                },
              ),

              const SizedBox(height: 20),

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
                selected: _selectedMealType,
                onChanged: isBusy
                    ? (_) {}
                    : (mealType) {
                        setState(() {
                          _selectedMealType = mealType;
                        });
                      },
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                label: 'บันทึกรายการที่เลือก',
                onPressed: hasConfirmedItem && !isBusy ? _saveLogs : null,
                isLoading: _isSaving,
              ),

              const SizedBox(height: 12),

              const Text(
                'หมายเหตุ: ตอนนี้ใช้ Mock AI สำหรับทดสอบ flow ก่อน เมื่อเชื่อม API จริงแล้วผลลัพธ์จะมาจากภาพอาหารจริง',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditableItem {
  final DetectedFoodItem detected;
  final TextEditingController nameController;
  bool isConfirmed;

  _EditableItem({
    required this.detected,
    required this.nameController,
    this.isConfirmed = true,
  });
}

class _DetectedItemRow extends StatelessWidget {
  final _EditableItem item;
  final VoidCallback? onToggle;

  const _DetectedItemRow({
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.isConfirmed
            ? AppColors.primarySurface
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isConfirmed ? AppColors.primary : AppColors.divider,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              item.isConfirmed
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: item.isConfirmed ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: item.nameController,
              enabled: onToggle != null,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.transparent,
                filled: false,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(item.detected.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}